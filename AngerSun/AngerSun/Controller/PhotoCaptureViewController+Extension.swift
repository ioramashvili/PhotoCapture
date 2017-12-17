import UIKit

extension PhotoCaptureViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        var selectedImageFromImagePicker: UIImage?
//
//        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
//            selectedImageFromImagePicker = editedImage.fixOrientation()
//        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            selectedImageFromImagePicker = originalImage.fixOrientation()
//        }
//
//        guard let image = selectedImageFromImagePicker else { return }
//        guard let activePoster = activePoster else { return }
//        guard let result = activePoster.filter(with: context, image: image) else { return }
//
//        currentState = .photoLibrary(image: result)
//        previewImageView.image = result
        
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        let imageCropInfo = ImageCropInfo(image: originalImage)
        guard let imageCropVC = AppStoryboard.photoLibrary.instantiate(controller: ImageCropViewController.self) else {return}
        imageCropVC.delegate = self
        imageCropVC.dataSource = imageCropInfo
        
        dismiss(animated: true) {
            self.present(imageCropVC, animated: true, completion: nil)
        }
    }
}

extension PhotoCaptureViewController {
    func updateBlurViewHole() {
        let rect = UIScreen.main.bounds
        
        let outerbezierPath = UIBezierPath(rect: rect)

        let y = (rect.height - rect.width) / 2
        let squareRect = CGRect(x: 0, y: y, width: rect.width, height: rect.width)
        
        let innerCirclepath = UIBezierPath(roundedRect: squareRect, cornerRadius: 0)
        outerbezierPath.append(innerCirclepath)
        outerbezierPath.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()
        fillLayer.path = outerbezierPath.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.green.cgColor
        
        let maskView = UIView(frame: rect)
        
        if #available(iOS 11, *) {
            maskView.backgroundColor = .clear
            maskView.layer.addSublayer(fillLayer)
        } else {
            maskView.backgroundColor = .black
            maskView.layer.mask = fillLayer
        }
        
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
