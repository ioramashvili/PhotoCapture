import UIKit

extension UIColor {
//    convenience init(name: AppColor) {
//        self.init(name: name.rawValue)
//    }
    
    convenience init(name: String) {
        let rgba = name.toUInt32.toRGBA
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
}

//extension AppColor {
//    var color : UIColor {
//        return UIColor(name: self)
//    }
//}

extension String {
    var toUInt32 : UInt32 {
        return UInt32(self, radix: 16)!
    }
}

extension UInt32 {
    var toRGBA : (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        get {
            let red   = CGFloat((self >> 24) & 0xff) / 255.0
            let green = CGFloat((self >> 16) & 0xff) / 255.0
            let blue  = CGFloat((self >>  8) & 0xff) / 255.0
            let alpha = CGFloat((self      ) & 0xff) / 255.0
            
            return (red, green, blue, alpha)
        }
    }
}
