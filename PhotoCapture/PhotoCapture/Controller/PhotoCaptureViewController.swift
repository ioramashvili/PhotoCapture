import UIKit
import AVFoundation

class PhotoCaptureViewController: UIViewController {

    fileprivate var pageViewController: PageViewController!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet var bluerView: UIVisualEffectView!
    fileprivate let flashView = UIView()
    
    fileprivate(set) var session = AVCaptureSession()
    fileprivate(set) var photoOutput = AVCapturePhotoOutput()
    fileprivate(set) var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    let videoOutput = AVCaptureVideoDataOutput()
    
    fileprivate var backCamera: AVCaptureDevice?
    fileprivate var frontCamera: AVCaptureDevice?
    
    lazy var openGLContext: EAGLContext = {
        return EAGLContext(api: .openGLES3)!
    }()
    
    lazy var context: CIContext = {
        return CIContext(eaglContext: openGLContext)
    }()
    
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        self.view.insertSubview(imageView, belowSubview: bluerView)
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        return imageView
    }()
    
    var activePoster: PosterDataProvider? {
        return pageViewController?.activePoster
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFlashView()
        
        setupVideoOutput()
        setupSession()
        setupVideoPreviewLayer()
        setupPhotoOutput()
        setupCameraAndStartSession()
        
        updateBlurViewHole()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPageViewController" {
            pageViewController = segue.destination as! PageViewController
            
            let posters: [PosterDataProvider] = [
                MonochromePoster(posterImage: #imageLiteral(resourceName: "s4"), intensity: 1, color: .black),
                MonochromePoster(posterImage: #imageLiteral(resourceName: "s1"), intensity: 0.5, color: .red),
                MonochromePoster(posterImage: #imageLiteral(resourceName: "s3"), intensity: 0.9, color: .blue),
                MonochromePoster(posterImage: #imageLiteral(resourceName: "s2"), intensity: 0.6, color: .green)
            ]
            
            pageViewController.dataProvider = posters
            pageViewController.pageControl = pageControl
        }
    }
    
    @IBAction func captureImageTapped(_ sender: UIButton) {
        captureButton.isEnabled = false
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        if (session.inputs.first as? AVCaptureDeviceInput)?.device.isFlashAvailable ?? false {
            settings.flashMode = .auto
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func swapCameras(_ sender: UIButton) {
        trySwapCameras()
    }
    
    @IBAction func chooseImage(_ sender: UIButton) {
        tryOpenImagePicker()
    }
    
    fileprivate func setupSession() {
        session.sessionPreset = AVCaptureSession.Preset.medium
    }
    
    fileprivate func setupPhotoOutput() {
        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])], completionHandler: nil)
    }
    
    fileprivate func setupVideoPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        videoPreviewLayer.frame = UIScreen.main.bounds
        
        previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
        previewView.isHidden = true
    }
    
    fileprivate func setupCameraAndStartSession() {
        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified).devices
        
        devices.forEach {
            switch $0.position {
            case .back:
                backCamera = $0
            case .front:
                frontCamera = $0
            default: break
            }
        }
        
        setupAVCaptureDeviceInput(for: backCamera)
    }
    
    fileprivate func trySwapCameras() {
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
        
        DispatchQueue
            .global(qos: .userInteractive)
            .asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
            self?.swapCameras()
        }
    }
    
    fileprivate func swapCameras() {
        guard let input = session.inputs[0] as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        defer {
            DispatchQueue.main.async {
                self.videoOutputOrientationToPortrait()
                self.session.commitConfiguration()
                self.setupVideoOutput()
            }
        }
        
        guard let newDevice = input.device.position == .back ? frontCamera : backCamera else {
            return
        }
        
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice)
        } catch {
            return
        }
        
        session.removeInput(input)
        session.addInput(deviceInput)
    }
    
    fileprivate func videoOutputOrientationToPortrait() {
        videoOutput.connections.forEach { $0.videoOrientation = .portrait }
    }
    
    var currentCaptureDevicePosistion: AVCaptureDevice.Position {
        guard let input = session.inputs.first as? AVCaptureDeviceInput else {
            return .unspecified
        }
        
        return input.device.position
    }
    
    fileprivate func setupVideoOutput() {
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
    }
    
    fileprivate func setupAVCaptureDeviceInput(for device: AVCaptureDevice?) {
        guard let device = device else {
            return
        }
        
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            print(error.localizedDescription)
        }
        
        if let input = input, session.canAddInput(input) {
            session.addInput(input)
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                
                session.startRunning()
                videoOutputOrientationToPortrait()
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)

                session.startRunning()
            }
        }
        
//        if let input = input, session.canAddInput(input) {
//            session.addInput(input)
//
//            if session.canAddOutput(photoOutput) {
//                session.addOutput(photoOutput)
//
//                session.startRunning()
//            }
//        }
    }
    
    fileprivate func setupFlashView() {
        flashView.translatesAutoresizingMaskIntoConstraints = false
        flashView.alpha = 0
        flashView.backgroundColor = .black
        previewView.addSubview(flashView)
        previewView.sendSubview(toBack: captureButton)
        
        flashView.topAnchor.constraint(equalTo: previewView.topAnchor).isActive = true
        flashView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
        flashView.leftAnchor.constraint(equalTo: previewView.leftAnchor).isActive = true
        flashView.rightAnchor.constraint(equalTo: previewView.rightAnchor).isActive = true
    }
    
    func animateFlashView() {
        UIView.animate(withDuration: 0.1) {
            self.flashView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            self.flashView.alpha = 0
        }, completion: nil)
    }
    
    func normalizedCapturedImage(data: Data?, position: AVCaptureDevice.Position, complition: @escaping (_ image: UIImage) -> Void) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let originalImage = data?.toImage else { return }
            guard var nomalizedImage = self.cropToPreviewLayer(originalImage: originalImage) else { return }
            
            guard let nomalizedImageCGImage = nomalizedImage.cgImage else { return }
            
            if position == .front {
                nomalizedImage = UIImage(cgImage: nomalizedImageCGImage, scale: nomalizedImage.scale, orientation: .leftMirrored)
            }
            
            nomalizedImage = nomalizedImage.fixOrientation()
            guard let squareImage = self.cropToCenterSquare(originalImage: nomalizedImage) else { return }
            
            guard let activePoster = self.activePoster else { return }
            guard let filteredImage = activePoster.filter(with: self.context, image: squareImage) else { return }
            guard let composition = self.activePoster?.mainPoster.normalizedCISourceOverCompositing(with: self.context, backgroundImage: filteredImage) else { return }
            
            DispatchQueue.main.async {
                print("nomalizedImage", nomalizedImage.size, nomalizedImage.imageOrientation.rawValue)
                print("Cropped", composition.size)
                complition(composition)
            }
        }
    }
    
    func showCaptured(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        let width = UIScreen.main.bounds.width
        let y = (UIScreen.main.bounds.height - width) / 2
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: y), size: CGSize(width: width, height: width))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewImageTapped(sender:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        view.addSubview(imageView)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction], animations: {
            imageView.frame.origin = CGPoint(x: 20, y: 50)
            imageView.frame.size = CGSize(width: 200, height: 200)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction], animations: {
                imageView.frame.origin.x -= 400
            }, completion: { _ in
                imageView.removeFromSuperview()
            })
        }
    }
    
    @objc fileprivate func previewImageTapped(sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView, let image = imageView.image else {
            return
        }
        
        share(image: image)
    }
    
    fileprivate func share(image: UIImage) {
        let imageToShare = [ image ]
        let activity = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activity.excludedActivityTypes = [.postToVimeo, .addToReadingList]
        
        present(activity, animated: true, completion: nil)
    }
}

