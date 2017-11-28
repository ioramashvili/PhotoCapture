import UIKit

class PosterTextCreationInfo {
    let capturedImage: UIImage
    let posterDataProvider: PosterDataProvider
    
    init(capturedImage: UIImage, posterDataProvider: PosterDataProvider) {
        self.capturedImage = capturedImage
        self.posterDataProvider = posterDataProvider
    }
}
