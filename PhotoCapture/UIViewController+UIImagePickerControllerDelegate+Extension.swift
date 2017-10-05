import UIKit
import PhotosUI

extension UIImagePickerControllerDelegate where Self: UIViewController {
    func tryOpenImagePicker() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        let showImagePicker = {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        switch status {
        case .authorized, .notDetermined:
            showImagePicker()
        case .restricted, .denied:
            print("showAcessDeniedAlert")
//            showAcessDeniedAlert(for: .photoLibrary)
        }
    }
}
