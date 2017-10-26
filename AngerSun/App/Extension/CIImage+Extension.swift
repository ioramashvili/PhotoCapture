import UIKit

protocol Monochromable: class {
    func addCIColorMonochrome(with context: CIContext, intensity: NSNumber, color: UIColor) -> UIImage?
}

extension CIImage: Monochromable {
    func addCIColorMonochrome(with context: CIContext, intensity: NSNumber, color: UIColor) -> UIImage? {
        guard let filter = CIFilter(name: "CIColorMonochrome") else { return nil }
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        filter.setValue(CIColor(color: .red), forKey: kCIInputColorKey)
        
        let ouputImage = filter.filteredOutputImage(with: context)
//        let randomImage = CIRandomGenerator(with: context, inputImageRect: CGRect(origin: .zero, size: ouputImage!.size))
//        let colorMatrix = CIColorMatrix(with: context, inputImage: CIImage(cgImage: randomImage!.cgImage!))
//        let combine = colorMatrix?.addCISourceOverCompositing(with: context, backgroundImage: ouputImage!)
        
        return ouputImage
    }
    
    func CIRandomGenerator(with context: CIContext, inputImageRect: CGRect) -> UIImage? {
        guard let filter = CIFilter(name: "CIRandomGenerator") else { return nil }
        
        guard
            let exposureOutput = filter.outputImage,
            let output = context.createCGImage(exposureOutput, from: inputImageRect) else {
                return nil
        }

        return UIImage(cgImage: output)
    }
    
    func CIColorMatrix(with context: CIContext, inputImage: CIImage) -> UIImage? {
        guard let filter = CIFilter(name: "CIColorMatrix") else { return nil }
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputRVector")
        filter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        filter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputBVector")
        
        filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        
        let outputImage = filter.filteredOutputImage(with: context)
        
        return outputImage
    }
}

extension CIImage {
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
        
        let result = filter.filteredOutputImage(with: context)
        
        return result
    }
}




