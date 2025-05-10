//
//  NSImageView+ImageLoader.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import AppKit
import SwiftlyImageLoader

public extension NSImageView {
    func setImage(
        from url: URL?,
        placeholder: NSImage? = nil,
        transform: (@Sendable (NSImage) -> NSImage)? = nil,
        completion: ((NSImage?) -> Void)? = nil
    ) {
        self.image = placeholder
        guard let url = url else { return }

        ImageLoader.shared.loadImage(from: url) { [weak self] loadedImage in
            guard let self = self, let img = loadedImage else { return }
            DispatchQueue.main.async { self.image = img }
        }
    }

    func cancelImageLoad(for url: URL?) {
        guard let url = url else { return }
        ImageLoader.shared.cancelLoad(for: url)
    }
}

#if os(macOS)
public enum ImageTransforms {
    public static func circular(for size: CGSize) -> (@Sendable (NSImage) -> NSImage) {
        return { $0.circular(size: size) }
    }
    public static func resized(to size: CGSize) -> (@Sendable (NSImage) -> NSImage) {
        return { $0.resized(to: size) }
    }
    public static func grayscale() -> (@Sendable (NSImage) -> NSImage) {
        return { $0.applyGrayscaleFilter() }
    }
}
#endif
