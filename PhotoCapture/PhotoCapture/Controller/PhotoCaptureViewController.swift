import UIKit
import AVFoundation

class PhotoCaptureViewController: UIViewController {

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
    
    lazy var fillLayer: CAShapeLayer = {
        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.green.cgColor
        
        return fillLayer
    }()
    
    lazy var maskView: UIView = {
        let maskView = UIView(frame: UIScreen.main.bounds)
        maskView.clipsToBounds = true
        maskView.backgroundColor = .clear
        
        maskView.layer.addSublayer(fillLayer)
        
        return maskView
    }()
    
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        self.view.insertSubview(imageView, aboveSubview: bluerView)
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFlashView()
        
        setupSession()
        setupVideoPreviewLayer()
        setupPhotoOutput()
        setupCameraAndStartSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureButton.layer.borderColor = UIColor.red.cgColor
        captureButton.layer.cornerRadius = captureButton.bounds.width / 2
        captureButton.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateBlurViewHole()
    }
    
    @IBAction func captureImageTapped(_ sender: UIButton) {
        captureButton.isEnabled = false
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func swapCameras(_ sender: UIButton) {
        swapCamera()
    }
    
    @IBAction func chooseImage(_ sender: UIButton) {
        tryOpenImagePicker()
    }
    
    fileprivate func setupSession() {
        session.sessionPreset = AVCaptureSession.Preset.photo
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
    
    fileprivate func swapCamera() {
        guard let input = session.inputs[0] as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        guard let newDevice = input.device.position == .back ? frontCamera : backCamera else {
            return
        }
        
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        session.removeInput(input)
        session.addInput(deviceInput)
        videoOutputOrientationToPortrait()
    }
    
    fileprivate func videoOutputOrientationToPortrait() {
        videoOutput.connections.forEach { $0.videoOrientation = .portrait }
    }
    
    fileprivate var currentCaptureDevicePosistion: AVCaptureDevice.Position {
        guard let input = session.inputs.first as? AVCaptureDeviceInput else {
            return .unspecified
        }
        
        return input.device.position
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
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
        
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
    
    fileprivate func animateFlashView() {
        UIView.animate(withDuration: 0.1) {
            self.flashView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            self.flashView.alpha = 0
        }, completion: nil)
    }
    
    fileprivate func previewCapturedImage(data: Data?, position: AVCaptureDevice.Position) {
        
        guard
            let imageData = data,
            let originamImage = UIImage(data: imageData),
            var nomalizedImage = cropToPreviewLayer(originalImage: originamImage) else {
            return
        }
        
        if position == .front {
            nomalizedImage = UIImage(cgImage: nomalizedImage.cgImage!, scale: nomalizedImage.scale, orientation: .leftMirrored)
        }
        
        print("NormalizedCGImage", nomalizedImage.size, nomalizedImage.imageOrientation)
        
        nomalizedImage = nomalizedImage.fixOrientation()
        
        guard
            let image = cropToCenterSquare(originalImage: nomalizedImage),
            let cgImage = image.cgImage,
            let filteredImage = CIImage(cgImage: cgImage).addFilter(with: context) else {
            return
        }
    
        print("Cropped", image.size)
        
        showCaptured(filteredImage)

//        share(image: image)
    }
    
    fileprivate func showCaptured(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.frame = CGRect(origin: CGPoint(x: -200, y: 50), size: CGSize(width: 200, height: 200))
        imageView.alpha = 0
        
        view.addSubview(imageView)
        
        UIView.animate(withDuration: 0.4, animations: {
            imageView.frame.origin = CGPoint(x: 20, y: 50)
            imageView.alpha = 1
        })
        
        UIView.animate(withDuration: 0.6, delay: 3, options: .curveEaseInOut, animations: {
            imageView.frame.origin.x -= 400
            imageView.alpha = 0
        }, completion: { _ in
            imageView.removeFromSuperview()
        })
    }
    
    fileprivate func share(image: UIImage) {
        let imageToShare = [ image ]
        let activity = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activity.excludedActivityTypes = [.postToVimeo, .addToReadingList]
        
        present(activity, animated: true, completion: nil)
    }
}

extension PhotoCaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        defer {
            captureButton.isEnabled = true
        }
        
        animateFlashView()
        
        if
            let sampleBuffer = photoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
            
            previewCapturedImage(data: dataImage, position: currentCaptureDevicePosistion)
        }
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            captureButton.isEnabled = true
        }
        
        animateFlashView()
        
        previewCapturedImage(data: photo.fileDataRepresentation(), position: currentCaptureDevicePosistion)
        //        AudioServicesPlayAlertSound(1108)
    }
}

extension PhotoCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        
        guard var result = ciImage.addFilter(with: context) else { return }
        
        if currentCaptureDevicePosistion == .front {
            result = UIImage(cgImage: result.cgImage!, scale: result.scale, orientation: .upMirrored)
        }

        DispatchQueue.main.async { [weak self] in
            self?.previewImageView.image = result
        }
    }
}







