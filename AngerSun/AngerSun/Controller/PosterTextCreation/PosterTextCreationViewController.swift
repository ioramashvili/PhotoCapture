import UIKit

class PosterTextCreationViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var dataProvider: PosterTextCreationDataProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        scrollView.contentInset.top = (scrollView.frame.height - scrollView.contentSize.height) / 2
        
        textView.becomeFirstResponder()
    }
    
    @IBAction func saveButtonDidTap(_ sender: UIBarButtonItem) {
        guard let image = imageView.superview?.toImage() else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    override var keyScrollView: UIScrollView {
        get {
            return scrollView
        }
        set {
            
        }
    }
    
    override var constantBottomOffset: CGFloat {
        return 0
    }
    
    fileprivate func setupUI() {
        textView.delegate = self
//        textView.font = AppFont.base.with(size: 24)
        textView.textColor = .white
//        textView.placeholderColor = UIColor.white.withAlphaComponent(0.5)
        textView.backgroundColor = .clear
//        textView.textContainer.lineFragmentPadding = 0
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







