//
//  ImageResizer.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

#if canImport(UIKit)
import UIKit

public enum ImageResizer {
    public static func resize(image: UIImage, to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
#endif
