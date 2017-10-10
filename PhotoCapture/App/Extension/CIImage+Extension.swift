import UIKit

extension CIImage {
    func addFilter(with context: CIContext) -> UIImage? {
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(self, forKey: kCIInputImageKey)
//        filter.setValue(CIColor(color: .red), forKey: kCIInputColorKey)
        
//        filter.setValue(CIVector(cgPoint: CGPoint(x: extent.midX, y: extent.midY)), forKey: kCIInputCenterKey)
//        filter.setValue(extent.width / 4, forKey: kCIInputRadiusKey)
        
        guard
            let exposureOutput = filter.outputImage,
            let output = context.createCGImage(exposureOutput, from: exposureOutput.extent) else {
                return nil
        }
        
        return UIImage(cgImage: output)
    }
}
