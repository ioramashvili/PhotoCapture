import Foundation
import UIKit

class ImageCropInfo: ImageCropDataSource {

    fileprivate(set) var _image: UIImage
    
    init(image: UIImage) {
        _image = image
    }
    
    var croppableImage: UIImage {
        return _image
    }
}
