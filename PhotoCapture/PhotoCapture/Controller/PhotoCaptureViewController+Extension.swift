import UIKit

extension PhotoCaptureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromImagePicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromImagePicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromImagePicker = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoCaptureViewController {
    func updateBlurViewHole() {
        let outerbezierPath = UIBezierPath(roundedRect: bluerView.bounds, cornerRadius: 0)
        
        let y = (UIScreen.main.bounds.height - UIScreen.main.bounds.width) / 2
        let rect = CGRect(x: 0, y: y, width: view.bounds.width, height: view.bounds.width)
        let innerCirclepath = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        outerbezierPath.append(innerCirclepath)
        outerbezierPath.usesEvenOddFillRule = true
        
        fillLayer.path = outerbezierPath.cgPath
        
        bluerView.mask = maskView
    }
}

extension PhotoCaptureViewController {
    func cropToPreviewLayer(originalImage: UIImage) -> UIImage? {
        let outputRect = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: videoPreviewLayer.bounds)
        
        guard let cgImage = originalImage.cgImage else { return nil }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let cropRect = CGRect(
            x: outputRect.origin.x * width,
            y: outputRect.origin.y * height,
            width: outputRect.size.width * width,
            height: outputRect.size.height * height)
        
        guard let newCGImage = cgImage.cropping(to: cropRect) else { return nil }
        
        let croppedUIImage = UIImage(
            cgImage: newCGImage,
            scale: originalImage.scale,
            orientation: originalImage.imageOrientation)
        
        return croppedUIImage
    }
    
    func cropToCenterSquare(originalImage: UIImage) -> UIImage? {
        let croppingY = ceil((originalImage.size.height - originalImage.size.width) / 2)
        let croppingWidth = originalImage.size.width
        let croppingHeight = originalImage.size.width
        
        let croppingRect = CGRect(x: 0, y: croppingY, width: croppingHeight, height: croppingWidth)
        
        guard let cgImage = originalImage.cgImage?.cropping(to: croppingRect) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
