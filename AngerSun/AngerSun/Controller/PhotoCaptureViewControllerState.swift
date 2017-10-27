import UIKit

extension PhotoCaptureViewController {
    enum State {
        case liveCamera, photoLibrary(image: UIImage)
        
        var isLiveCamera: Bool {
            switch self {
            case .liveCamera: return true
            default: return false
            }
        }
        
        var photoLibraryImage: UIImage? {
            switch self {
            case .photoLibrary(let image): return image
            default: return nil
            }
        }
    }
}
