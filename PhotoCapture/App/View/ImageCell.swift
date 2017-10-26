import UIKit
import Photos

class ImageCell: UICollectionViewCell {
    
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage()
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage()
    }
    
    func configureWithModel(_ model: PHAsset) {
        
        if tag != 0 {
            PHImageManager.default().cancelImageRequest(PHImageRequestID(tag))
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        let size = CGSize(width: 180, height: 180)
        
        tag = Int(PHImageManager.default().requestImage(for: model, targetSize: size, contentMode: .default, options: options) { image, info in
            self.imageView.image = image
        })
    }
}


