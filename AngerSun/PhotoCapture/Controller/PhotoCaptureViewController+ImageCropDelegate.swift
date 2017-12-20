import UIKit

extension PhotoCaptureViewController: ImageCropDelegate {
    func croppingDidFinish(with image: UIImage) {
        currentState = .photoLibrary(image: image)
        guard let filteredImage = activePoster?.filter(with: self.context, image: image) else { return }
        previewImageView.image = filteredImage
    }
}
