import UIKit
import AVFoundation

extension PhotoCaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        defer {
            captureButton.isEnabled = true
        }
        
        animateFlashView()
        
        if
            let sampleBuffer = photoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
            
            normalizedCapturedImage(data: dataImage, position: currentCaptureDevicePosistion) { image in
                self.showCaptured(image)
            }
        }
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            captureButton.isEnabled = true
        }
        
        animateFlashView()
        
        normalizedCapturedImage(data: photo.fileDataRepresentation(), position: currentCaptureDevicePosistion) { image in
            self.showCaptured(image)
        }
        //        AudioServicesPlayAlertSound(1108)
    }
}








