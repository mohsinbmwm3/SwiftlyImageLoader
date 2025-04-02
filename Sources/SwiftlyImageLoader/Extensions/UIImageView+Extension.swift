//
//  UIImageView+Extension.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

#if canImport(UIKit)
import UIKit

public extension UIImageView {
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        self.image = placeholder
        guard let url = url else { return }

        ImageLoader.shared.loadImage(from: url) { [weak self] loadedImage in
            guard let self = self, let img = loadedImage else { return }
            self.image = img
        }
    }
}
#endif
