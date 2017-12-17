import UIKit

class BaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationController
            .viewControllers
            .flatMap({ $0 as? UINavigationControllerDelegate })
            .forEach { controller in
                controller.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
        
        print("did show", viewController.className)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController
            .viewControllers
            .flatMap({ $0 as? UINavigationControllerDelegate })
            .forEach { controller in
                controller.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
        
        print("will show", viewController.className)
    }
}

