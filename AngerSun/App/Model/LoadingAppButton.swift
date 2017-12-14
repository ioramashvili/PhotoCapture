import UIKit

@IBDesignable
class LoadingAppButton: UIButton {
    lazy var activiryIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .white)
        a.translatesAutoresizingMaskIntoConstraints = false
                
        addSubview(a)
        bringSubview(toFront: a)
        
        a.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        a.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        return a
    }()
    
    func startAnimating() {
        activiryIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activiryIndicator.stopAnimating()
    }
}
