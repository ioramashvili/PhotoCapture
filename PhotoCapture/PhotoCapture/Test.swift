import UIKit

class Test: UIViewController {
    
    override func viewDidLoad() {
        debugPrint("Running...")
        
        super.viewDidLayoutSubviews();
        
        // Lets load an image first, so blur looks cool
        let url = URL(string: "https://static.pexels.com/photos/168066/pexels-photo-168066-large.jpeg")
        
        URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
//                self.addTheBlurView(data: data!)
            })
            
            }.resume()
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func addTheBlurView(data: Data) {
        
        let generalFrame = self.view.bounds;
        let parentView = UIView(frame: generalFrame)
        self.view.addSubview(parentView)
        
        let imageView = UIImageView(frame: parentView.bounds)
        imageView.image = UIImage(data: data)
        imageView.contentMode = .scaleAspectFill
        
        let maskView = UIView(frame: parentView.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.layer.mask = { () -> CALayer in
            
            var square = CGRect(x: 0.0, y: 0.0, width: parentView.bounds.size.width, height: parentView.bounds.size.width)
            square.origin.x = (parentView.frame.size.width - square.size.width) / 2
            square.origin.y = (parentView.frame.size.height - square.size.height) / 2
            
            let path = UIBezierPath(rect: parentView.bounds)
            let croppedPath = UIBezierPath(rect: square)
            path.append(croppedPath)
            path.usesEvenOddFillRule = true
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillRule = kCAFillRuleEvenOdd
            
            return maskLayer
        }()
        
        let blurView = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurView)
        effectView.frame = generalFrame
        
        effectView.mask = maskView
        parentView.addSubview(imageView)
        parentView.addSubview(effectView)
    }
}
