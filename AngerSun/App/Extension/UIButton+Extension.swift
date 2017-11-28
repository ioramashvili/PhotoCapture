import UIKit

extension UIButton {
    func setImageAnimated(image: UIImage?) {
        let fade = CABasicAnimation(keyPath: "contents")
        fade.duration = 0.3
        fade.fromValue = imageView?.image?.mask(with: .white).cgImage
        fade.toValue = image?.mask(with: .white).cgImage
        fade.isRemovedOnCompletion = false
        fade.fillMode = kCAFillModeForwards
        imageView?.layer.add(fade, forKey: "fade")
        
        setImage(image, for: .normal)
    }
}
