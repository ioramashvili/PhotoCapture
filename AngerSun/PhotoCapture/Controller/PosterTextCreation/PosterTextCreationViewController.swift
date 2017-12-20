import UIKit

class PosterTextCreationViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewWrapper: UIView!
    
    @IBOutlet weak var appendingImageViewWrapper: UIView!
    @IBOutlet weak var appendingImageView: UIImageView!
    
    lazy var textView: UITextView = {
        let t = UITextView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.textColor = dataProvider.posterDataProvider.textColor
        t.font = dataProvider.posterDataProvider.font
        t.backgroundColor = .clear
        t.contentInset = .zero
        t.textContainer.lineFragmentPadding = 0
        t.textContainerInset = .zero
        t.isScrollEnabled = false
        t.returnKeyType = UIReturnKeyType.default
        t.keyboardAppearance = .dark
        t.textAlignment = .center
        t.autocorrectionType = .no
        
        return t
    }()
    
    var dataProvider: PosterTextCreationDataProvider!
    weak var photoCaptureSessionDelegate: PhotoCaptureSessionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StoreReviewHelper.increaseTargetCount()
        scrollView.keyboardDismissMode = .onDrag
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeKeyboardNotifications()
        
        if dataProvider.posterDataProvider.posterTextViewPosition != .none {
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
        
        if !dataProvider.posterDataProvider.hasOutsideComponent {
            appendingImageView.superview?.isHidden = true
        }

        scrollView.isScrollEnabled = dataProvider.posterDataProvider.posterTextViewPosition != .none
    }
    
    fileprivate func setupText() {
        switch dataProvider.posterDataProvider.posterTextViewPosition {
        case .none: break
        case .bottom:
            appendingImageViewWrapper.addSubview(textView)
            textView.leadingAnchor.constraint(equalTo: appendingImageViewWrapper.leadingAnchor, constant: 20).isActive = true
            textView.trailingAnchor.constraint(equalTo: appendingImageViewWrapper.trailingAnchor, constant: -20).isActive = true
            textView.centerYAnchor.constraint(equalTo: appendingImageViewWrapper.centerYAnchor, constant: 0).isActive = true
        case .insideTop:
            imageViewWrapper.addSubview(textView)
            textView.leadingAnchor.constraint(equalTo: imageViewWrapper.leadingAnchor, constant: 5).isActive = true
            textView.trailingAnchor.constraint(equalTo: imageViewWrapper.trailingAnchor, constant: -5).isActive = true
            textView.topAnchor.constraint(equalTo: imageViewWrapper.topAnchor, constant: 5).isActive = true
        }
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
        
        return numberOfLines <= CGFloat(dataProvider.posterDataProvider.maxTextViewLine)
    }
}







