import UIKit

extension Data {
    var toImage: UIImage? {
        return UIImage(data: self)
    }
}
