//
//  ImageLoader.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias CrossPlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias CrossPlatformImage = NSImage
#endif

public final class ImageLoader: @unchecked Sendable {
    
    /// Singleton instance for convenient shared use.
    public static let shared = ImageLoader()
    
    /// Current configuration used by the image loader.
    private(set) var config: SwiftlyImageLoaderConfiguration = .default
    private let session: URLSession = .shared
    private var ongoingTasks = [URL: (task: Task<Void, Never>, completions: [@Sendable (CrossPlatformImage?) -> Void])]()
    private let taskQueue = DispatchQueue(label: "com.swiftlyImageLoader.taskQueue")

    private init() {}
    
    /// Configures the shared image loader instance with custom settings.
    /// - Parameter config: A `SwiftlyImageLoaderConfiguration` object.
    public static func setup(with config: SwiftlyImageLoaderConfiguration) {
        shared.config = config
    }

    /// Loads an image asynchronously from a URL, with optional transformation and caching.
    ///
    /// This method checks the in-memory cache and disk cache before attempting a network download.
    /// An optional image transformation closure can be applied to modify the image (e.g., resizing, cropping, filtering)
    /// before it is cached and returned.
    ///
    /// - Parameters:
    ///   - url: The URL from which to load the image.
    ///   - transform: An optional closure to transform the loaded image before caching and display.
    ///   - completion: A closure called with the final image or `nil` if loading fails.

    public func loadImage(from url: URL,
                          transform: (@Sendable (CrossPlatformImage) -> CrossPlatformImage)?,
                          completion: @escaping @Sendable (CrossPlatformImage?) -> Void) {
        taskQueue.async {
            if let existing = self.ongoingTasks[url] {
                self.log("🔁 Joining existing task for: \(url.absoluteString)", level: .verbose)
                self.ongoingTasks[url]?.completions.append(completion)
                return
            }

            self.log("🟡 Starting image load for: \(url.absoluteString)", level: .basic)

            let task = Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let key = url.absoluteString

                if let data = await ImageCache.shared.get(forKey: key), let image = CrossPlatformImage(data: data) {
                    self.log("✅ Loaded from memory cache: \(url.absoluteString)", level: .basic)

                    let finalImage = await MainActor.run {
                        transform?(image) ?? image
                    }

                    self.callCompletions(for: url, with: finalImage)
                    return
                }

                if let data = await DiskCache.shared.get(forKey: key), let image = CrossPlatformImage(data: data) {
                    self.log("✅ Loaded from disk cache: \(url.absoluteString)", level: .basic)
                    
                    let finalImage = await MainActor.run {
                        transform?(image) ?? image
                    }
                    
                    if let finalData = finalImage.pngData() {
                        await ImageCache.shared.set(finalData, forKey: key)
                    }
                    
                    self.callCompletions(for: url, with: finalImage)
                    return
                }

                do {
                    let (data, _) = try await self.session.data(from: url)
                    if let image = CrossPlatformImage(data: data) {
                        self.log("✅ Downloaded from network: \(url.absoluteString)", level: .basic)
                        let finalImage = await MainActor.run {
                            transform?(image) ?? image
                        }
                        
                        let finalData: Data?
                        switch config.imageEncoding {
                        case .png:
                            finalData = finalImage.pngData()
                        case .jpeg(let quality):
                            finalData = finalImage.jpegData(compressionQuality: quality)
                        }
                        
                        if let finalData = finalImage.pngData() {
                            await ImageCache.shared.set(finalData, forKey: key)
                            await DiskCache.shared.save(finalData, forKey: key)
                        }
                        self.callCompletions(for: url, with: finalImage)
                    } else {
                        self.log("⚠️ Failed to decode image: \(url.absoluteString)", level: .basic)
                        self.callCompletions(for: url, with: nil)
                    }
                } catch is CancellationError {
                    self.log("🛑 Cancelled image load: \(url.absoluteString)", level: .verbose)
                    self.callCompletions(for: url, with: nil)
                } catch {
                    self.log("❌ Error loading image: \(url.absoluteString) - \(error.localizedDescription)", level: .basic)
                    self.callCompletions(for: url, with: nil)
                }
            }

            self.ongoingTasks[url] = (task: task, completions: [completion])
        }
    }

    private func callCompletions(for url: URL, with image: CrossPlatformImage?) {
        taskQueue.async {
            let completions = self.ongoingTasks[url]?.completions ?? []
            self.ongoingTasks[url] = nil
            DispatchQueue.main.async {
                completions.forEach { $0(image) }
            }
        }
    }
    
    /// Cancels any in-progress image loading task for the specified URL.
    /// - Parameter url: The URL for which to cancel the task.
    public func cancelLoad(for url: URL) {
        taskQueue.async {
            if let entry = self.ongoingTasks[url] {
                self.log("🔴 Cancelling task for: \(url.absoluteString)", level: .verbose)
                entry.task.cancel()
                self.ongoingTasks[url] = nil
            }
        }
    }

    /// Cancels all ongoing image loading tasks if enabled in config.
    public func cancelAll() {
        guard config.enableGlobalCancellation else { return }
        taskQueue.async {
            self.log("🔻 Cancelling all ongoing image loads", level: .verbose)
            self.ongoingTasks.values.forEach { $0.task.cancel() }
            self.ongoingTasks.removeAll()
        }
    }

    private func log(_ message: String, level: LogLevel) {
        guard config.logLevel != .none else { return }
        if config.logLevel == .verbose || level == .basic {
            print(message)
        }
    }
}
