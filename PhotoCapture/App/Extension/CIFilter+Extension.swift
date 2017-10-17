import UIKit

extension CIFilter {
    func filteredOutputImage(with context: CIContext) -> UIImage? {
        guard
            let exposureOutput = outputImage,
            let output = context.createCGImage(exposureOutput, from: exposureOutput.extent) else {
                return nil
        }
        
        return UIImage(cgImage: output)
    }
}
