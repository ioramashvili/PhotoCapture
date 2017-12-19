import UIKit
import AVFoundation
import LSFramework

class PhotoCaptureViewController: PushViewControllerNotifiableViewController {

    var currentState: State = .liveCamera {
        didSet {
            print("current state to", currentState)
            
            let isLiveCamera = currentState.isPhotoLibrary
            liveCameraControlSW.isHidden = isLiveCamera
            
            flashModeButton.isHidden = isLiveCamera
            photoLibraryControlSW.isHidden = !liveCameraControlSW.isHidden
            
            let contentMode: UIViewContentMode = !isLiveCamera ? .scaleAspectFill : .scaleAspectFit
            previewImageView.contentMode = contentMode
            
            let backgroundColor: UIColor = !isLiveCamera ? .clear : .black
            topBlurOverlay.backgroundColor = backgroundColor
            bottomBlurOverlay.backgroundColor = backgroundColor
        }
    }
    
    fileprivate let cameraQueue = DispatchQueue(label: "com.angersun.cameraqueue")
    
    fileprivate(set) var currentFlashMode: AVCaptureDevice.FlashMode = .off {
        didSet {
            flashModeButton.setImageAnimated(image: flashModes[currentFlashMode])
        }
    }
    
    fileprivate let flashModes: [AVCaptureDevice.FlashMode: UIImage] = [.off: #imageLiteral(resourceName: "flash-off"), .on: #imageLiteral(resourceName: "flash-on"), .auto: #imageLiteral(resourceName: "flash-auto")]
    
    @IBOutlet weak var flashModeButton: UIButton!
    
    @IBOutlet weak var topBlurOverlay: UIView!
    @IBOutlet weak var bottomBlurOverlay: UIView!
    
    @IBOutlet weak var liveCameraControlSW: UIStackView!
    @IBOutlet weak var photoLibraryControlSW: UIStackView!
    
    fileprivate var pageViewController: PosterPageViewController!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: LoadingAppButton!
    @IBOutlet var bluerView: UIVisualEffectView!
    fileprivate let flashView = UIView()
    
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var swapCameraButton: UIButton!
    
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
    
    lazy var animatePageViewController: Void = {
        self.pageViewController.view.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.pageViewController.view.alpha = 0
        self.pageViewController.view.isHidden = false
        self.pageControl.isHidden = false
        
        UIView.animate(withDuration: 0.55, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.pageViewController.view.transform = .identity
            self.pageViewController.view.alpha = 1
        }, completion: nil)
    }()
    
    fileprivate func pageViewControllerToInitialState() {
        pageViewController.view.isHidden = true
        pageControl.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewControllerToInitialState()
        
        currentFlashModeToOff()
        checkPermissions()
        
        cameraNotReady()
        addCameraObserver()
        
        setupFlashView()
        
        setupVideoOutput()
        setupSession()
        setupVideoPreviewLayer()
        setupPhotoOutput()
        setupCameraAndStartSession()
        
        updateBlurViewHole()
        
        currentState = .liveCamera
        
        setupFocusGesture()
    }
    
    @objc func focusGesture(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: view)
        
        let rect = CGRect(
            x: 0,
            y: (view.bounds.height - view.bounds.width) / 2,
            width: view.bounds.width,
            height: view.bounds.width)
        
        guard rect.contains(point) else {return}
        
        focusCamera(to: point)
    }
    
    @discardableResult
    public func focusCamera(to point: CGPoint) -> Bool {
        guard let input = session.inputs.first as? AVCaptureDeviceInput else {
            return false
        }
        
        let device = input.device
        guard device.isFocusModeSupported(.continuousAutoFocus) else {
            return false
        }
        
        do { try device.lockForConfiguration() } catch {
            return false
        }
        
        let focusPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
        
        device.focusPointOfInterest = focusPoint
        device.focusMode = .continuousAutoFocus
        
        device.exposurePointOfInterest = focusPoint
        device.exposureMode = .continuousAutoExposure
        
        device.unlockForConfiguration()
        
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentState = .sleepLiveCamera
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPosterPageViewController" {
            pageViewController = segue.destination as! PosterPageViewController

            pageViewController.posterPageDelegate = self
            pageViewController.dataProvider = Poster.getPosters()
            pageViewController.pageControl = pageControl
        }
    }
    
    @IBAction func donePhotoLibraryActionTapped(_ sender: UIButton) {
        guard let photoLibraryImage = currentState.photoLibraryImage else {return}
        
        normalize(image: photoLibraryImage, for: activePoster) { image in
            self.showCaptured(image)
        }
    }
    
    @IBAction func calncelPhotoLibraryActionTapped(_ sender: UIButton) {
//        session.startRunning()
        currentState = .liveCamera
    }
    
    @IBAction func filterIntensityTapped(_ sender: UIButton) {
        let intensity = Double(sender.tag) / 100
        (activePoster as? MonochromePoster)?.intensity = NSNumber(value: intensity)
    }
    
    @IBAction func captureImageTapped(_ sender: LoadingAppButton) {
        captureButton.isEnabled = false
        sender.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = currentFlashMode
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func flashModeDidTap(_ sender: UIButton) {
        currentFlashModeToNext()
    }
    
    fileprivate func currentFlashModeToOff() {
        currentFlashMode = .off
    }
    
    fileprivate func currentFlashModeToNext() {
        let isFlashAvailable = (session.inputs.first as? AVCaptureDeviceInput)?.device.isFlashAvailable ?? false
        if !isFlashAvailable {
            currentFlashModeToOff()
            return
        }
        
        let modeIndex = currentFlashMode.rawValue
        let nextIndex = modeIndex + 1
        let normalizedNextIndex = nextIndex > 2 ? 0 : nextIndex
        guard let nextMode = AVCaptureDevice.FlashMode(rawValue: normalizedNextIndex) else {return}
        currentFlashMode = nextMode
    }
    
    @IBAction func swapCameras(_ sender: UIButton) {
        trySwapCameras()
    }
    
    @IBAction func chooseImage(_ sender: UIButton) {
        guard let photoLibraryWrapper = AppStoryboard.photoLibrary.instantiate(controller: PhotoLibraryWrapper.self) else {return}
        photoLibraryWrapper.delegate = self
        photoLibraryWrapper.photoCaptureSessionDelegate = self
        
        present(photoLibraryWrapper, animated: true) { [weak self] in
            self?.currentState = .sleepLiveCamera
        }
    }
    
    fileprivate func addCameraObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyCameraReady),
            name: NSNotification.Name.AVCaptureSessionDidStartRunning,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cameraNotReady),
            name: NSNotification.Name.AVCaptureSessionDidStopRunning,
            object: nil)
    }
    
    @objc func notifyCameraReady() {
        [captureButton, photoLibraryButton, swapCameraButton].forEach { $0?.isEnabled = true }
        pageViewController.view.isUserInteractionEnabled = true
        
        _ = animatePageViewController
    }
    
    @objc func cameraNotReady() {
        [captureButton, photoLibraryButton, swapCameraButton].forEach { $0?.isEnabled = false }
    }
    
    fileprivate func setupSession() {
        session.sessionPreset = AVCaptureSession.Preset.high
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
    
    fileprivate func setupFocusGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(focusGesture(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    fileprivate func trySwapCameras() {
        swapCameras()
    }
    
    fileprivate func swapCameras() {
        guard let input = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        session.removeInput(input)
        
        guard let newDevice = input.device.position == .back ? frontCamera : backCamera else {
            return
        }
        
        guard let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
            return
        }
        
        session.addInput(newInput)
        rotatePreview()
        session.commitConfiguration()
        currentFlashModeToOff()
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
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.angersun.cameradelegate"))
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
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
        }
        
        cameraQueue.sync {
            session.startRunning()
            DispatchQueue.main.async() { [weak self] in
                self?.rotatePreview()
            }
        }
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
    
    func normalize(image: UIImage, for poster: PosterDataProvider?, complition: @escaping (_ image: UIImage) -> Void) {
        guard let poster = poster else {return}
        DispatchQueue.global(qos: .userInteractive).async {
            guard let filteredImage = poster.filter(with: self.context, image: image) else { return }
            guard let composition = poster.mainPoster.normalizedCISourceOverCompositing(with: self.context, backgroundImage: filteredImage) else { return }
            
            DispatchQueue.main.async {
                print("Cropped", composition.size)
                complition(composition)
            }
        }
    }
    
    func showCaptured(_ image: UIImage) {
        let controller = storyboard!.instantiate(controller: PosterTextCreationViewController.self)!
        controller.dataProvider = PosterTextCreationInfo(capturedImage: image, posterDataProvider: activePoster!)
        controller.photoCaptureSessionDelegate = self
        navigationController?.pushViewController(viewController: controller, willShow: { }, didShow: {
            self.currentState = .sleepLiveCamera
        }, animated: true)
    }
    
    @objc fileprivate func previewImageTapped(sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView, let image = imageView.image else {return}
        
        share(image: image)
    }
    
    fileprivate func rotatePreview() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            videoPreviewLayer?.connection?.videoOrientation = .portrait
            videoOutput.connections.first?.videoOrientation = .portrait
            break
        case .portraitUpsideDown:
            videoPreviewLayer?.connection?.videoOrientation = .portraitUpsideDown
            videoOutput.connections.first?.videoOrientation = .portraitUpsideDown
            break
        case .landscapeRight:
            videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
            videoOutput.connections.first?.videoOrientation = .landscapeRight
            break
        case .landscapeLeft:
            videoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
            videoOutput.connections.first?.videoOrientation = .landscapeLeft
            break
        default: break
        }
    }
    
    fileprivate func checkPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async() { [weak self] in
                    if !granted {
                        self?.openAppPermisions()
                    }
                }
            }
        case .denied, .restricted:
            openAppPermisions()
        default: break
        }
    }
}

extension PhotoCaptureViewController: PosterPageDelegate {
    func pageChanged(to poster: PosterDataProvider, at index: Int) {
        guard let photoLibraryImage = currentState.photoLibraryImage else {return}
        DispatchQueue.global(qos: .userInteractive).async {
            guard let filteredImage = poster.filter(with: self.context, image: photoLibraryImage) else { return }
            
            DispatchQueue.main.async {
                self.previewImageView.image = filteredImage
            }
        }
    }
}

extension PhotoCaptureViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print("did show", viewController.className)
        
        if viewController.className == PosterTextCreationViewController.className {
            currentState = .liveCamera
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("will show", viewController.className)
    }
}

extension PhotoCaptureViewController: PhotoCaptureSessionDelegate {
    func startRunning() {
        session.startRunning()
        currentState = .liveCamera
    }
}

protocol PhotoCaptureSessionDelegate: class {
    func startRunning()
}

