import UIKit

enum AppFont: String {
    case base = "XeroxSansSerifWideFC-Bold"
    
    func with(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
    
    static func printFontNames() {
        for family in UIFont.familyNames {
            print("\(family)")
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
}

