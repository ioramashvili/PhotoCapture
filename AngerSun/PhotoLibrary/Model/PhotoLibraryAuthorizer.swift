import UIKit
import Photos

public typealias PhotoLibraryAuthorizerCompletion = (String?) -> Void

class PhotoLibraryAuthorizer {

    private let completion: PhotoLibraryAuthorizerCompletion

    init(completion: @escaping PhotoLibraryAuthorizerCompletion) {
        self.completion = completion
        handleAuthorization(status: PHPhotoLibrary.authorizationStatus())
    }
    
    func onDeniedOrRestricted(completion: PhotoLibraryAuthorizerCompletion) {
        completion("error")
    }
    
    func handleAuthorization(status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(handleAuthorization)
        case .authorized:
            DispatchQueue.main.async {
                self.completion(nil)
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.onDeniedOrRestricted(completion: self.completion)
            }
        }
    }
}
