//
//  DiskCache.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import Foundation

/// Persistent Storage
/// Survives app restarts
/// Used when image isn’t in memory but already downloaded before
/// Saves bandwidth, avoids redundant downloads
/// Acts as a fallback layer behind memory cache
actor DiskCache: @unchecked Sendable {
    static let shared = DiskCache()

    private let fileManager = FileManager.default
    private let directory: URL

    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        self.directory = paths[0].appendingPathComponent("SwiftlyImageLoader")

        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    /// To support disk TTL, we should:
    /// 1. Save the timestamp along with the image file
    /// 2. When loading, check if the image is expired based on diskCacheTTL
    /// 3. If expired, delete it and return nil
    /// Image.jpg and Image.meta ← contains timestamp
    func save(_ data: Data, forKey key: String) async {
        let fileURL = directory.appendingPathComponent(key.safeFileName())
        try? data.write(to: fileURL)

        let timestamp = Date().timeIntervalSince1970
        let metaURL = fileURL.appendingPathExtension("meta")
        try? "\(timestamp)".data(using: .utf8)?.write(to: metaURL)
    }

    func get(forKey key: String) -> Data? {
        let fileURL = directory.appendingPathComponent(key.safeFileName())
        let metaURL = fileURL.appendingPathExtension("meta")

        if let ttl = ImageLoader.shared.config.diskCacheTTL,
           let timestampData = try? Data(contentsOf: metaURL),
           let timestampString = String(data: timestampData, encoding: .utf8),
           let timestamp = TimeInterval(timestampString) {
            if Date().timeIntervalSince1970 - timestamp > ttl {
                try? fileManager.removeItem(at: fileURL)
                try? fileManager.removeItem(at: metaURL)
                return nil
            }
        }

        return try? Data(contentsOf: fileURL)
    }
}

private extension String {
    func safeFileName() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
    }
}
