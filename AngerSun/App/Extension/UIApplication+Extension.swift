import Foundation
import UIKit

extension UIApplication {
    static var safeAreaInsets: UIEdgeInsets {
        let insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        if #available(iOS 11.0, *) {
            guard let safeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets else {
                return insets
            }
            
            return safeAreaInsets
        }
        
        return insets
    }
}

