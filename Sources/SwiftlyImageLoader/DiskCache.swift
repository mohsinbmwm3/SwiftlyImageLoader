//
//  DiskCache.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import Foundation

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

    func save(_ data: Data, forKey key: String) async {
        let fileURL = directory.appendingPathComponent(key.safeFileName())
        try? data.write(to: fileURL)
    }

    func get(forKey key: String) -> Data? {
        let fileURL = directory.appendingPathComponent(key.safeFileName())
        return try? Data(contentsOf: fileURL)
    }
}

private extension String {
    func safeFileName() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
    }
}
