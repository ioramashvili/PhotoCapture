import UIKit
import AVFoundation

extension PhotoCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard currentState.isLiveCamera, let activePoster = activePoster else { return }
//        print(arc4random_uniform(100))
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        guard var result = activePoster.filter(with: context, ciImage: ciImage) else { return }
        if let resultCGImage = result.cgImage, currentCaptureDevicePosistion == .front {
            result = UIImage(cgImage: resultCGImage, scale: result.scale, orientation: .upMirrored)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {return}
            guard strongSelf.currentState.isLiveCamera else {return}
            strongSelf.previewImageView.image = result
        }
    }
}
