import UIKit

class PosterTextCreationViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var appendingImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var dataProvider: PosterTextCreationDataProvider!
    weak var photoCaptureSessionDelegate: PhotoCaptureSessionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StoreReviewHelper.increaseTargetCount()
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
    
    fileprivate func createPoster() -> UIImage? {
        var image: UIImage?
        
        if textView.text.isEmpty {
            image = imageView.toImage()
        } else {
            image = imageView.superview?.toImage()
        }
        
        return image
    }
    
    @IBAction func saveButtonDidTap(_ sender: UIButton) {
        closeVC()
        
        guard let poster = createPoster() else {return}
        
        DispatchQueue.global(qos: .userInteractive).async {
            UIImageWriteToSavedPhotosAlbum(poster, nil, nil, nil)
        }
    }
    
    @IBAction func shareButtonDidTap(_ sender: UIButton) {
        textView.resignFirstResponder()
        
        guard let poster = createPoster() else {return}
        
        share(image: poster)
    }
    
    @IBAction func cancelButtonDidTap(_ sender: UIButton) {
        textView.resignFirstResponder()
        closeVC()
    }
    
    fileprivate func closeVC() {
        photoCaptureSessionDelegate?.startRunning()
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
        textView.textColor = .white
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







