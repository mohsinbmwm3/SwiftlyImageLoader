//
//  ImageCache.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import Foundation

final class CacheEntry {
    let data: Data
    let timestamp: Date

    init(data: Data, timestamp: Date = Date()) {
        self.data = data
        self.timestamp = timestamp
    }
}

/// In-Memory Cache
/// Volatile: cleared on memory pressure or app relaunch
/// Ideal for images already being displayed or used recently
/// Automatically handles eviction under low memory
/// Used for instant UI feedback (like while scrolling)
actor ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, CacheEntry>()
    private var ttl: TimeInterval? { ImageLoader.shared.config.memoryCacheTTL }

    private init() {}

    /// Stores image data in the memory cache under the provided key.
    /// - Parameters:
    ///   - data: The image data to store.
    ///   - key: The key associated with this image, typically the URL string.
    func set(_ data: Data, forKey key: String) {
        let entry = CacheEntry(data: data)
        cache.setObject(entry, forKey: key as NSString)
    }

    /// Retrieves cached data if available and not expired.
    /// - Parameter key: The cache key (usually the URL string).
    /// - Returns: Cached image data or nil if not found or expired.
    func get(forKey key: String) -> Data? {
        guard let entry = cache.object(forKey: key as NSString) else { return nil }
        if let ttl = ttl, Date().timeIntervalSince(entry.timestamp) > ttl {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return entry.data
    }
}

