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

    private init() {}

    public func loadImage(from url: URL, completion: @escaping @Sendable (CrossPlatformImage?) -> Void) {
        let session = self.session

        Task.detached(priority: .userInitiated) { [completion] in
            let key = url.absoluteString

            if let data = await ImageCache.shared.get(forKey: key), let image = CrossPlatformImage(data: data) {
                DispatchQueue.main.async { completion(image) }
                return
            }

            if let data = await DiskCache.shared.get(forKey: key), let image = CrossPlatformImage(data: data) {
                await ImageCache.shared.set(data, forKey: key)
                DispatchQueue.main.async { completion(image) }
                return
            }

            do {
                let (data, _) = try await session.data(from: url)
                if let image = CrossPlatformImage(data: data) {
                    await ImageCache.shared.set(data, forKey: key)
                    await DiskCache.shared.save(data, forKey: key)
                    DispatchQueue.main.async { completion(image) }
                } else {
                    DispatchQueue.main.async { completion(nil) }
                }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
