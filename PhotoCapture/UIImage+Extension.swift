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
    
    func tryFilter() -> UIImage? {
        guard let cgimg = cgImage else {
            print("imageView doesn't have an image!")
            return nil
        }
        
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        
        let coreImage = CIImage(cgImage: cgimg)
//
//        let filter = CIFilter(name: "CIColorMonochrome")!
//        filter.setValue(coreImage, forKey: kCIInputImageKey)
//        filter.setValue(2, forKey: kCIInputIntensityKey)
//        filter.setValue(CIColor(red: 0.7, green: 1, blue: 1), forKey: kCIInputColorKey)
        
        
        let filter = CIFilter(name: "CICrystallize")!
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        
        guard
            let exposureOutput = filter.outputImage,
            let output = context.createCGImage(exposureOutput, from: exposureOutput.extent) else {
            return nil
        }
        
        let result = UIImage(cgImage: output)
        
        return result
        
//        if let sepiaOutput = sepiaFilter.value(forKey: kCIOutputImageKey) as? CIImage {
//            let exposureFilter = CIFilter(name: "CIExposureAdjust")!
//            exposureFilter.setValue(sepiaOutput, forKey: kCIInputImageKey)
//            exposureFilter.setValue(1, forKey: kCIInputEVKey)
//
//            if let exposureOutput = exposureFilter.value(forKey: kCIOutputImageKey) as? CIImage {
//                let output = context.createCGImage(exposureOutput, from: exposureOutput.extent)
//                let result = UIImage(cgImage: output!)
//                return result
//            }
//        }
    }
}



