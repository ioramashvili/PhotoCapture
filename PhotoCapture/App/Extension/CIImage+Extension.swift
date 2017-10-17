import UIKit

extension CIImage {
    func addCIColorMonochrome(with context: CIContext, intensity: NSNumber = 1) -> UIImage? {
        guard let filter = CIFilter(name: "CIColorMonochrome") else { return nil }
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(CIColor(color: .red), forKey: kCIInputColorKey)
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        
        return filter.filteredOutputImage(with: context)
    }
    
    func addCILanczosScaleTransform(with context: CIContext, scale: NSNumber) -> UIImage? {
        guard let filter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        
        return filter.filteredOutputImage(with: context)
    }
    
    func addCISourceOverCompositing(with context: CIContext, backgroundImage: UIImage) -> UIImage? {
        guard let backgroundCGImage = backgroundImage.cgImage else { return nil }
        let backgroundCIImage = CIImage(cgImage: backgroundCGImage)
        
        guard let filter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(backgroundCIImage, forKey: kCIInputBackgroundImageKey)
        
        return filter.filteredOutputImage(with: context)
    }
}



