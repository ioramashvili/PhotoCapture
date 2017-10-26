import UIKit

extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    func tryCreateCIImage() -> CIImage? {
        guard let backgroundCGImage = cgImage else { return nil }
        let backgroundCIImage = CIImage(cgImage: backgroundCGImage)
        
        return backgroundCIImage
    }
    
    func addCILanczosScaleTransform(with context: CIContext, scale: NSNumber) -> UIImage? {
        return tryCreateCIImage()?.addCILanczosScaleTransform(with: context, scale: scale)
    }
    
    func addCISourceOverCompositing(with context: CIContext, backgroundImage: UIImage) -> UIImage? {
        return tryCreateCIImage()?.addCISourceOverCompositing(with: context, backgroundImage: backgroundImage)
    }
    
    func normalizedCISourceOverCompositing(with context: CIContext, backgroundImage: UIImage) -> UIImage? {
        
        let scale = NSNumber(value: Double(backgroundImage.size.width / size.width) * Double(backgroundImage.scale))
        
        guard let scaledForegroundImage = addCILanczosScaleTransform(with: context, scale: scale) else { return nil }
        
        let result = scaledForegroundImage.addCISourceOverCompositing(with: context, backgroundImage: backgroundImage)
        
        return result
    }
}

extension UIImage: Monochromable {
    func addCIColorMonochrome(with context: CIContext, intensity: NSNumber, color: UIColor) -> UIImage? {
        return tryCreateCIImage()?.addCIColorMonochrome(with: context, intensity: intensity, color: color)
    }
}



