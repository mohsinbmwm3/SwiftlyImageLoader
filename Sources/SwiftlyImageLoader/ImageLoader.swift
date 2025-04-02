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
    private let session: URLSession = .shared
    private var ongoingTasks = [URL: Task<Void, Never>]()
    private let taskQueue = DispatchQueue(label: "com.swiftlyImageLoader.taskQueue")

    private init() {}

    public func loadImage(from url: URL, completion: @escaping @Sendable (CrossPlatformImage?) -> Void) {
        cancelLoad(for: url)
        print("🟡 Starting image load for: \(url.absoluteString)")

        let session = self.session

        let task = Task.detached(priority: .userInitiated) { [completion] in
            let key = url.absoluteString

            if let data = await ImageCache.shared.get(forKey: key), let image = CrossPlatformImage(data: data) {
                print("✅ Loaded from memory cache: \(url.absoluteString)")
                DispatchQueue.main.async { completion(image) }
                return
            }

            if let data = await DiskCache.shared.get(forKey: key), let image = CrossPlatformImage(data: data) {
                print("✅ Loaded from disk cache: \(url.absoluteString)")
                await ImageCache.shared.set(data, forKey: key)
                DispatchQueue.main.async { completion(image) }
                return
            }

            do {
                let (data, _) = try await session.data(from: url)
                if let image = CrossPlatformImage(data: data) {
                    print("✅ Downloaded from network: \(url.absoluteString)")
                    await ImageCache.shared.set(data, forKey: key)
                    await DiskCache.shared.save(data, forKey: key)
                    DispatchQueue.main.async {
                        completion(image)
                        self.taskQueue.async {
                            self.ongoingTasks[url] = nil
                        }
                    }
                } else {
                    print("⚠️ Failed to decode image: \(url.absoluteString)")
                    DispatchQueue.main.async {
                        completion(nil)
                        self.taskQueue.async {
                            self.ongoingTasks[url] = nil
                        }
                    }
                }
            } catch is CancellationError {
                print("🛑 Cancelled image load: \(url.absoluteString)")
            } catch {
                print("❌ Error loading image: \(url.absoluteString) - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                    self.taskQueue.async {
                        self.ongoingTasks[url] = nil
                    }
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
                print("🔴 Cancelling task for: \(url.absoluteString)")
                task.cancel()
                self.ongoingTasks[url] = nil
            }
        }
    }
}
