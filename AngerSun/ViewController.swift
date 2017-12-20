import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    func addTheBlurView() {
        
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = #imageLiteral(resourceName: "flag")
        imageView.contentMode = .scaleAspectFill
        
        let maskView = UIView(frame: UIScreen.main.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.layer.mask = { () -> CALayer in
            var roundedRect = CGRect(
                x: 0.0,
                y: 0.0,
                width: UIScreen.main.bounds.size.width * 0.5,
                height: UIScreen.main.bounds.size.width * 0.5
            );
            roundedRect.origin.x = UIScreen.main.bounds.size.width / 2 - roundedRect.size.width / 2
            roundedRect.origin.y = UIScreen.main.bounds.size.height / 2 - roundedRect.size.height / 2
            
            let cornerRadius = roundedRect.size.height / 2.0;
            
            let path = UIBezierPath(rect: UIScreen.main.bounds)
            let croppedPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
            path.append(croppedPath)
            path.usesEvenOddFillRule = true
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillRule = kCAFillRuleEvenOdd
            return maskLayer
        }()
        
        
        blurView.isHidden = true
        
        let b = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: b)
        effectView.frame = UIScreen.main.bounds
        
        effectView.mask = maskView
        view.addSubview(imageView)
        view.sendSubview(toBack: imageView)
        view.addSubview(effectView)
    }
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addTheBlurView()
    }
    
    override func viewDidLayoutSubviews() {
//        addTheBlurView()
    }
}
