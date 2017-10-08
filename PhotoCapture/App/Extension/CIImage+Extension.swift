import UIKit

extension CIImage {
    func addFilter(with context: CIContext) -> UIImage? {
        guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(1, forKey: kCIInputIntensityKey)
        
        guard
            let exposureOutput = filter.outputImage,
            let output = context.createCGImage(exposureOutput, from: exposureOutput.extent) else {
                return nil
        }
        
        return UIImage(cgImage: output)
    }
}
