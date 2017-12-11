import UIKit

class PosterTextCreationViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var appendingImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var dataProvider: PosterTextCreationDataProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.keyboardDismissMode = .interactive
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeKeyboardNotifications()
        
        if dataProvider.posterDataProvider.isTextAppandable {
            textView.becomeFirstResponder()
        }
    }
    
    @IBAction func shareButtonDidTap(_ sender: UIButton) {
        textView.resignFirstResponder()
        
        var image: UIImage?
        if textView.text.isEmpty {
            image = imageView.toImage()
        } else {
            image = imageView.superview?.toImage()
        }
        
        guard let sharableImage = image else {return}
        
        UIImageWriteToSavedPhotosAlbum(sharableImage, nil, nil, nil)
        share(image: sharableImage)
    }
    
    @IBAction func cancelButtonDidTap(_ sender: UIButton) {
        textView.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    override var keyScrollView: UIScrollView {
        return scrollView
    }
    
    override var constantBottomOffset: CGFloat {
        return 38
    }
    
    fileprivate func setupUI() {
        setupText()
        
        imageView.image = dataProvider.capturedImage
        appendingImageView.image = dataProvider.posterDataProvider.appendableImage
        
        if !dataProvider.posterDataProvider.isTextAppandable {
            appendingImageView.superview?.isHidden = true
        }

        scrollView.isScrollEnabled = dataProvider.posterDataProvider.isTextAppandable
    }
    
    fileprivate func setupText() {
        textView.delegate = self
//        textView.font = AppFont.base.with(size: 24)
        textView.textColor = .white
//        textView.placeholderColor = UIColor.white.withAlphaComponent(0.5)
        textView.backgroundColor = .clear
        textView.contentInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.returnKeyType = UIReturnKeyType.default
    }
}

extension PosterTextCreationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    fileprivate func sizeOfString(string: String, constrainedToWidth width: CGFloat, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(
            with: CGSize(width: width, height: CGFloat.infinity),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: font],
            context: nil).size
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)

        let boundingRect = sizeOfString(string: newText, constrainedToWidth: textView.frame.width, font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight
        
        return numberOfLines <= 2
    }
}







