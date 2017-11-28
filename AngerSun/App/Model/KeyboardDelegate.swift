import Foundation
import UIKit

@objc protocol KeyboardDelegate: class {
    var keyScrollView: UIScrollView { get set }
    var isKeyboardOpen: Bool { get set }
    var keyboardFrame: CGRect { get set }
    var constantBottomOffset: CGFloat { get }
    
    func keyboardWillShow(notification: NSNotification)
    func keyboardWillHide(notification: NSNotification)
    func keyboardWillChangeFrame(notification: NSNotification)
    func keyboardDidChangeFrame(notification: NSNotification)
}

extension KeyboardDelegate where Self: UIViewController {
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        var userInfo = notification.userInfo!
        let _UIKeyboardFrameEndUserInfoKey = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = _UIKeyboardFrameEndUserInfoKey.cgRectValue
        return keyboardFrame.size.height
    }
    
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector:
            #selector(keyboardWillChangeFrame),
            name: NSNotification.Name.UIKeyboardWillChangeFrame,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidChangeFrame),
            name: NSNotification.Name.UIKeyboardDidChangeFrame,
            object: nil)
    }
}

