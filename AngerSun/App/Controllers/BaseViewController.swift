import UIKit

class BaseViewController: UIViewController {
    
    fileprivate var _keyboardFrame = CGRect.zero
    fileprivate var _isKeyboardOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BaseViewController: KeyboardDelegate {
    var keyScrollView: UIScrollView {
        get {
            return UIScrollView()
        }
        set {
            
        }
    }
    
    var isKeyboardOpen: Bool {
        get {
            return _isKeyboardOpen
        }
        set {
            _isKeyboardOpen = newValue
        }
    }
    
    var keyboardFrame: CGRect {
        get {
            return _keyboardFrame
        }
        set {
            _keyboardFrame = newValue
        }
    }
    
    var constantBottomOffset: CGFloat {
        return 20
    }
    
    func keyboardWillShow(notification: NSNotification) {
        isKeyboardOpen = true
        keyScrollView.contentInset.bottom = getKeyboardHeight(notification) + constantBottomOffset
        
        // ვაკლებთ iPhone X-ის გამო
        keyScrollView.contentInset.bottom -= UIApplication.safeAreaInsets.bottom
    }
    
    func keyboardWillHide(notification: NSNotification) {
        isKeyboardOpen = false
        keyScrollView.contentInset.bottom = 0
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        let _UIKeyboardFrameEndUserInfoKey = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboardFrame = _UIKeyboardFrameEndUserInfoKey.cgRectValue
    }
    
    func keyboardDidChangeFrame(notification: NSNotification) {
        
    }
}
