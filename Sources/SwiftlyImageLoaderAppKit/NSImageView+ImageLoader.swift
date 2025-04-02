//
//  NSImageView+ImageLoader.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import AppKit
import SwiftlyImageLoader

public extension NSImageView {
    func setImage(from url: URL?, placeholder: NSImage? = nil) {
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
