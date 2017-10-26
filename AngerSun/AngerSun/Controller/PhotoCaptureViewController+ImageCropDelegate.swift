import UIKit

extension PhotoCaptureViewController: ImageCropDelegate {
    func croppingDidFinish(with image: UIImage) {
        currentState = .photoLibrary(image: image)
        previewImageView.image = image
    }
}
