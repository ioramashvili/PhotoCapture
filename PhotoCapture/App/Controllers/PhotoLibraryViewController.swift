import UIKit
import Photos

class PhotoLibraryViewController: UIViewController {

    fileprivate var assets: PHFetchResult<PHAsset>? = nil
    fileprivate let itemSpacing: CGFloat = 1
    fileprivate let columns: CGFloat = 4
    
    weak var delegate: PhotoLibraryDelegate?
    weak var photoLibraryWrapperDelegate: PhotoLibraryWrapperDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let thumbnailDimension = (UIScreen.main.bounds.width - ((columns * itemSpacing) - itemSpacing))/columns
        
        layout.itemSize = CGSize(width: thumbnailDimension, height: thumbnailDimension)
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubview(collectionView)
        
        _ = ImageFetcher()
            .onFailure(onFailure)
            .onSuccess(onSuccess)
            .fetch()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func onFailure(_ error: String) {
//        let permissionsView = PermissionsView(frame: view.bounds)
//        permissionsView.titleLabel.text = localizedString("permissions.library.title")
//        permissionsView.descriptionLabel.text = localizedString("permissions.library.description")
//
//        view.addSubview(permissionsView)
    }
    
    private func onSuccess(_ photos: PHFetchResult<PHAsset>) {
        assets = photos
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.className)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    fileprivate func itemAtIndexPath(_ indexPath: IndexPath) -> PHAsset? {
        return assets?[(indexPath as NSIndexPath).row]
    }
    
    @IBAction func close() {
        photoLibraryWrapperDelegate?.closeVC()
    }
}

extension PhotoLibraryViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageCell = cell as? ImageCell else {return}
        
        if let model = itemAtIndexPath(indexPath) {
            imageCell.configureWithModel(model)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.className, for: indexPath)
    }
}

extension PhotoLibraryViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = itemAtIndexPath(indexPath)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset!, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { image, info in
            
            guard let image = image else {return}
            self.delegate?.didSelect(image: image)
            
//            guard let originalImage = image else {return}
//            let imageCropInfo = ImageCropInfo(image: originalImage)
//            guard let imageCropVC = AppStoryboard.imageCrop.instantiate(controller: ImageCropViewController.self) else {return}
//            imageCropVC.delegate = self
//            imageCropVC.dataSource = imageCropInfo
//
//            DispatchQueue.main.async {
//                self.present(imageCropVC, animated: false, completion: nil)
//            }
        }
    }
}

protocol PhotoLibraryDelegate: class {
    func didSelect(image: UIImage)
}

extension PhotoLibraryViewController: ImageCropDelegate {
    func croppingDidFinish(with image: UIImage) {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
}









