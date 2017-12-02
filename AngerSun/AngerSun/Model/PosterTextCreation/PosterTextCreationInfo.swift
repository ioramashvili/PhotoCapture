import UIKit

class PosterTextCreationInfo: PosterTextCreationDataProvider {
    let capturedImage: UIImage
    let posterDataProvider: PosterDataProvider
    
    init(capturedImage: UIImage, posterDataProvider: PosterDataProvider) {
        self.capturedImage = capturedImage
        self.posterDataProvider = posterDataProvider
    }
}
