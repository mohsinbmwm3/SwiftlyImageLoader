//
//  UIImageView+Extension.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

#if canImport(UIKit)
import UIKit

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
#endif
