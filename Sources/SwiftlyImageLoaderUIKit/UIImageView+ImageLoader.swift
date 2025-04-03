//
//  Untitled.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import UIKit
import SwiftlyImageLoader

/// Extension that adds image loading capability to `UIImageView` using `SwiftlyImageLoader`.
/// This enables asynchronous image loading with placeholder support, caching, and cancellation.
public extension UIImageView {
    @MainActor
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        self.image = placeholder
        guard let url = url else { return }

        ImageLoader.shared.loadImage(from: url) { [weak self] loadedImage in
            guard let self = self, let img = loadedImage else { return }
            Task { @MainActor in
                self.image = img
            }
        }
    }

    func cancelImageLoad(for url: URL?) {
        guard let url = url else { return }
        ImageLoader.shared.cancelLoad(for: url)
    }
}
