import UIKit

@IBDesignable
class AppButton: UIButton {
    
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
    
    fileprivate lazy var shadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        
        layer.insertSublayer(shadowLayer, at: 0)
        return shadowLayer
    }()
    
    @IBInspectable
    var shadowRadius: CGFloat = 0 {
        didSet {
            updateShadowPath()
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 0 {
        didSet {
            shadowLayer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize = .zero {
        didSet {
            shadowLayer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor = .clear {
        didSet {
            shadowLayer.shadowColor = shadowColor.cgColor
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            shadowLayer.fillColor = backgroundColor?.cgColor
        }
    }
    
    fileprivate func updateShadowPath() {
        layer.cornerRadius = shadowRadius
        
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: shadowRadius).cgPath
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shouldRasterize = true
        shadowLayer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateShadowPath()
    }
}




