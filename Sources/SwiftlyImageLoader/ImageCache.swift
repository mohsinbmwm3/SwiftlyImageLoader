//
//  ImageCache.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import Foundation

actor ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, NSData>()

    private init() {}

    /// Stores image data in the memory cache under the provided key.
    /// - Parameters:
    ///   - data: The image data to store.
    ///   - key: The key associated with this image, typically the URL string.
    func set(_ data: Data, forKey key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }

    
    func get(forKey key: String) -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }
}

