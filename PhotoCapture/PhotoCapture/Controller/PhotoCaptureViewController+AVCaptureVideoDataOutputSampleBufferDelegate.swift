import UIKit
import AVFoundation

extension PhotoCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        
        guard let activePoster = activePoster else { return }
        
        guard var result = activePoster.filter(with: context, ciImage: ciImage) else { return }
//        guard var result = ciImage.addCIColorMonochrome(with: context, intensity: 0.5, color: .red) else { return }
        
        if currentCaptureDevicePosistion == .front {
            result = UIImage(cgImage: result.cgImage!, scale: result.scale, orientation: .upMirrored)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.previewImageView.image = result
        }
    }
}
