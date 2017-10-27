import UIKit
import PhotosUI

extension UIImagePickerControllerDelegate where Self: UIViewController {
    func tryOpenImagePicker(allowsEditing: Bool) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        let showImagePicker = {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.allowsEditing = allowsEditing
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        switch status {
        case .authorized, .notDetermined:
            showImagePicker()
        case .restricted, .denied:
            openAppPermisions()
        }
    }
}
