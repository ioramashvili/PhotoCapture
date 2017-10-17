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
    
    func addCIColorMonochrome(with context: CIContext) -> UIImage? {
        return tryCreateCIImage()?.addCIColorMonochrome(with: context)
    }
    
    func addCILanczosScaleTransform(with context: CIContext, scale: NSNumber) -> UIImage? {
        return tryCreateCIImage()?.addCILanczosScaleTransform(with: context, scale: scale)
    }
    
    func addCISoftLightBlendMode(with context: CIContext, backgroundImage: UIImage) -> UIImage? {
        return tryCreateCIImage()?.addCISoftLightBlendMode(with: context, backgroundImage: backgroundImage)
    }
}



