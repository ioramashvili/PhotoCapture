import UIKit

class PhotoLibraryWrapper: UIViewController {

    fileprivate var photoLibraryVC: PhotoLibraryViewController!
    fileprivate var imageCropVC: ImageCropViewController!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: ImageCropDelegate?
    weak var photoCaptureSessionDelegate: PhotoCaptureSessionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        scrollView.backgroundColor = .black
        scrollView.isScrollEnabled = false
        scrollView.isPagingEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhotoLibraryViewController" {
            let nc = segue.destination as! UINavigationController
            photoLibraryVC = nc.viewControllers.first as! PhotoLibraryViewController
            
            photoLibraryVC.photoLibraryWrapperDelegate = self
            photoLibraryVC.delegate = self
        } else if segue.identifier == "goToImageCropViewController" {
            imageCropVC = segue.destination as! ImageCropViewController
            
            imageCropVC.photoLibraryWrapperDelegate = self
            imageCropVC.delegate = self
        }
    }
    
    func goToPhotoLibraryViewController() {
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.scrollView.contentOffset.x = 0
        }, completion: { (bool: Bool) in
            
        })
    }
    
    func goToImageCropViewController() {
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.scrollView.contentOffset.x = self.view.frame.width
        }, completion: { (bool: Bool) in
            
        })
    }
}

extension PhotoLibraryWrapper: PhotoLibraryWrapperDelegate {
    func closeVC() {
        photoCaptureSessionDelegate?.stopRunning()
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.45, animations: {
            self.view.alpha = 0
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension PhotoLibraryWrapper: ImageCropDelegate {
    func croppingDidFinish(with image: UIImage) {
        delegate?.croppingDidFinish(with: image)
        
        closeVC()
    }
}

extension PhotoLibraryWrapper: PhotoLibraryDelegate {
    func didSelect(image: UIImage) {
        let imageCropInfo = ImageCropInfo(image: image)
        
        imageCropVC.dataSource = imageCropInfo
        imageCropVC.setupScrollView(image: image)
        
        goToImageCropViewController()
    }
}



