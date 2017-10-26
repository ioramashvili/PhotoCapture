import UIKit
import Foundation

enum AppStoryboard: String {
    case main = "Main"
    case imageCrop = "ImageCrop"
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: nil)
    }
    
    func instantiate<T: UIViewController>(controller: T.Type) -> T? {
        return storyboard.instantiateViewController(withIdentifier: T.className) as? T
    }
}
