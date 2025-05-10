#if canImport(UIKit)
import UIKit

public extension UIImage {

    /// Resize image to the specified size.
    func resized(to targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = self.scale
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    /// Convert the image to grayscale using Core Image.
    func applyGrayscaleFilter() -> UIImage {
        guard let ciImage = CIImage(image: self) else { return self }

        let filter = CIFilter(name: "CIPhotoEffectMono")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        guard let output = filter?.outputImage else { return self }

        let context = CIContext()
        if let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        }

        return self
    }

    /// Crop the image into a circular shape.
    func circular(size: CGSize) -> UIImage {
        if size.width == 0 || size.height == 0 {
            return self // fallback: return original image
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.addEllipse(in: rect)
            context.cgContext.clip()
            self.draw(in: rect)
        }
    }
}
#endif

#if os(macOS)
import AppKit

public extension NSImage {

    /// Resize image to the specified size.
    func resized(to targetSize: CGSize) -> NSImage {
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: targetSize),
                  from: .zero,
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }

    /// Crop the image into a circular shape.
    func circular() -> NSImage {
        let minEdge = min(size.width, size.height)
        let targetSize = CGSize(width: minEdge, height: minEdge)

        let image = NSImage(size: targetSize)
        image.lockFocus()

        let path = NSBezierPath(ovalIn: CGRect(origin: .zero, size: targetSize))
        path.addClip()
        self.draw(in: CGRect(origin: .zero, size: targetSize),
                  from: .zero,
                  operation: .copy,
                  fraction: 1.0)

        image.unlockFocus()
        return image
    }

    /// Convert the image to grayscale using Core Image.
    func applyGrayscaleFilter() -> NSImage {
        guard let tiffData = self.tiffRepresentation,
              let ciImage = CIImage(data: tiffData) else { return self }

        let filter = CIFilter(name: "CIPhotoEffectMono")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        guard let output = filter?.outputImage else { return self }

        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return self }

        let size = self.size
        let rep = NSBitmapImageRep(cgImage: cgImage)
        let outputImage = NSImage(size: size)
        outputImage.addRepresentation(rep)
        return outputImage
    }
}
#endif
