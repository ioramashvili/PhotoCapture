import UIKit

protocol ImageCropDelegate: class {
    func croppingDidFinish(with image: UIImage)
}
