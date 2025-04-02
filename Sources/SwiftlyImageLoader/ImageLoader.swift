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
    public static let shared = ImageLoader()
    
    private(set) var config: SwiftlyImageLoaderConfiguration = .default
    private let session: URLSession = .shared
    private var ongoingTasks = [URL: Task<Void, Never>]()
    private let taskQueue = DispatchQueue(label: "com.swiftlyImageLoader.taskQueue")

    private init() {}
    
    public static func setup(with config: SwiftlyImageLoaderConfiguration) {
        shared.config = config
    }

    public func loadImage(from url: URL, completion: @escaping @Sendable (CrossPlatformImage?) -> Void) {
        if config.cancelPreviousLoadForSameURL {
            cancelLoad(for: url)
        }

        log("🟡 Starting image load for: \(url.absoluteString)", level: .basic)
        let session = self.session

        let task = Task.detached(priority: .userInitiated) { [completion] in
            let key = url.absoluteString

            if let data = await ImageCache.shared.get(forKey: key), let image = CrossPlatformImage(data: data) {
                self.log("✅ Loaded from memory cache: \(url.absoluteString)", level: .basic)
                DispatchQueue.main.async {
                    completion(image)
                    self.taskQueue.async { self.ongoingTasks[url] = nil }
                }
                return
            }

            if let data = await DiskCache.shared.get(forKey: key), let image = CrossPlatformImage(data: data) {
                self.log("✅ Loaded from disk cache: \(url.absoluteString)", level: .basic)
                await ImageCache.shared.set(data, forKey: key)
                DispatchQueue.main.async {
                    completion(image)
                    self.taskQueue.async { self.ongoingTasks[url] = nil }
                }
                return
            }

            do {
                let (data, _) = try await session.data(from: url)
                if let image = CrossPlatformImage(data: data) {
                    self.log("✅ Downloaded from network: \(url.absoluteString)", level: .basic)
                    await ImageCache.shared.set(data, forKey: key)
                    await DiskCache.shared.save(data, forKey: key)
                    DispatchQueue.main.async {
                        completion(image)
                        self.taskQueue.async { self.ongoingTasks[url] = nil }
                    }
                } else {
                    self.log("⚠️ Failed to decode image: \(url.absoluteString)", level: .basic)
                    DispatchQueue.main.async {
                        completion(nil)
                        self.taskQueue.async { self.ongoingTasks[url] = nil }
                    }
                }
            } catch is CancellationError {
                self.log("🛑 Cancelled image load: \(url.absoluteString)", level: .verbose)
            } catch {
                self.log("❌ Error loading image: \(url.absoluteString) - \(error.localizedDescription)", level: .basic)
                DispatchQueue.main.async {
                    completion(nil)
                    self.taskQueue.async { self.ongoingTasks[url] = nil }
                }
            }
        }

        taskQueue.async {
            self.ongoingTasks[url] = task
        }
    }

    public func cancelLoad(for url: URL) {
        taskQueue.async {
            if let task = self.ongoingTasks[url] {
                self.log("🔴 Cancelling task for: \(url.absoluteString)", level: .verbose)
                task.cancel()
                self.ongoingTasks[url] = nil
            }
        }
    }

    public func cancelAll() {
        guard config.enableGlobalCancellation else { return }
        taskQueue.async {
            self.log("🔻 Cancelling all ongoing image loads", level: .verbose)
            self.ongoingTasks.values.forEach { $0.cancel() }
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
