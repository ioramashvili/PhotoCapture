import UIKit

@IBDesignable
class AppButton: UIButton {
    
    @IBInspectable
    var hasSquareBorderRadius: Bool = false {
        didSet {
            updateShadowPath()
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat = 0 {
        didSet {
            updateShadowPath()
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable
    var appButtonBackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = nil
            layer.backgroundColor = appButtonBackgroundColor.cgColor
        }
    }
    
    fileprivate func updateShadowPath() {
        let cornerRadius = hasSquareBorderRadius ? bounds.height / 2 : shadowRadius
        
        layer.cornerRadius = cornerRadius
        
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateShadowPath()
    }
}




