import UIKit

class ImageCropViewController: UIViewController {
    
    @IBOutlet weak var cropAreaView: CropAreaView!
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.delegate = self
        
        self.view.addSubview(scrollView)
        self.view.sendSubview(toBack: scrollView)
        
        return scrollView
    }()
    
    fileprivate var imageView: UIImageView!
    
    weak var delegate: ImageCropDelegate?
    weak var photoLibraryWrapperDelegate: PhotoLibraryWrapperDelegate?
    
    var dataSource: ImageCropDataSource?
    
    fileprivate var cropAreaHeight: CGFloat {
        return cropAreaView.frame.height
    }
    
    fileprivate var cropAreaWidth: CGFloat {
        return cropAreaView.frame.width
    }
    
    fileprivate var cropRect: CGRect {
        return CGRect(
            x: 0,
            y: ceil(UIScreen.main.bounds.height - UIScreen.main.bounds.width) / 2,
            width: cropAreaWidth,
            height: cropAreaHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        scrollView.backgroundColor = .clear
        automaticallyAdjustsScrollViewInsets = false
        
        setupScrollView(image: dataSource?.croppableImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
    func setupScrollView(image: UIImage?) {
        guard let image = image else {return}
        
        imageView?.removeFromSuperview()
        imageView = nil
        
        imageView = UIImageView(image: image)
        
        scrollView.addSubview(imageView)
        
        setZoomScale()
        scrollViewDidZoom()
    }
    
    fileprivate func closeVC() {
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.45, animations: {
            self.view.alpha = 0
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        photoLibraryWrapperDelegate?.goToPhotoLibraryViewController()
    }
    
    @IBAction func crop(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        
        guard let screenshot = view.snapshot(of: cropRect) else {
            sender.isUserInteractionEnabled = true
            return
        }
        
        delegate?.croppingDidFinish(with: screenshot)
    }
    
    fileprivate func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        let minimumZoomScale = max(scrollViewSize.width / imageViewSize.height, scrollViewSize.width / imageViewSize.width)
        
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = max(max(widthScale, heightScale), minimumZoomScale)
        scrollView.zoomScale = min(scrollView.minimumZoomScale, scrollView.maximumZoomScale)
    }
    
    fileprivate func scrollViewDidZoom() {
        scrollView.contentInset = UIEdgeInsets(top: cropRect.origin.y, left: 0, bottom: cropRect.origin.y, right: 0)
        imageView.frame.origin = .zero
    }
    
    fileprivate func calculateImageViewFrameInScrollView() -> CGPoint {
        let scrollViewSize = scrollView.bounds.size
        let minScale:CGFloat = 1
        let scaledSize = CGSize(width: imageView.frame.width * minScale, height: imageView.frame.height * minScale)
        let verticalPadding = scaledSize.height < scrollViewSize.height ? (scrollViewSize.height - scaledSize.height) / 2 : 0
        let horizontalPadding = scaledSize.width < scrollViewSize.width ? (scrollViewSize.width - scaledSize.width) / 2 : 0
        
        return CGPoint(x: horizontalPadding, y: verticalPadding - scrollView.contentInset.top)
    }
}

extension ImageCropViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension UIView {
    fileprivate func snapshot(of rect: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = wholeImage, let rect = rect else { return wholeImage }
        
        let scale = image.scale
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale)
        
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        
        let result = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        
        return result
    }
}
