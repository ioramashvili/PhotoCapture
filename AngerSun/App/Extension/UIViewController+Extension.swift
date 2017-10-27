import UIKit

extension UIViewController {
    func openAppPermisions() {
        DispatchQueue.main.async {
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
    }
}
