//
//  ScanCodeCtrlr.swift
//  MediaCaptureTutorial
//
//  Created by cp3hnu on 2021/12/23.
//

import UIKit
import AVFoundation

final class ScanCodeCtrlr: UIViewController {

    private let sessionQueue = DispatchQueue(label: "session queue")
    private let captureSession = AVCaptureSession()
    private var scanLine: UIImageView!
    private let previewView = CapturePreviewView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "扫一扫"
        self.view.backgroundColor = UIColor.black
        setupView()
        
//        PrivacyManager.sharedInstance.rx_cameraStatus
//            .subscribeNext { [weak self] status in
//                if status == PermissionStatus.authorized {
//                    onMainQueue {
//                       self?.setupView()
//                    }
//                } else if status == PermissionStatus.unauthorized {
//                    self?.privacyUnauthorized(PermissionType.camera,
//                        cancelBlock: {
//                            self?.navigationController?.popViewController(animated: true)
//                        }, settingBlock: {
//                            self?.navigationController?.popViewController(animated: false)
//                    })
//                }
//            }.disposed(by: disposeBag)
//
//        NotificationCenter.default.rx.notification(NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange)
//            .subscribeNext { [weak self] _ in
//                if let strongSelf = self {
//                    let rect = strongSelf.previewLayer.metadataOutputRectConverted(fromLayerRect: strongSelf.scannerRect())
//                    strongSelf.metadataOutput.rectOfInterest = rect
//                }
//            }.disposed(by: disposeBag)
        
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    deinit {
        print("ScanCodeCtrlr")
    }
}

// MARK: - Configure Session
private extension ScanCodeCtrlr {
    func selectBackCaptureDevice() -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .builtInTrueDepthCamera,
            .builtInTelephotoCamera,
            .builtInUltraWideCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,
            .builtInTripleCamera
        ]
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back)
        return discoverySession.devices.first
    }
    
    func configureSession() {
        guard let captureDevice = selectBackCaptureDevice() else { return }
        guard let captureDeviceInput: AVCaptureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else { return }
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.pdf417]
    }
}

// MARK: - Setup
private extension ScanCodeCtrlr {
    func setupView() {
        print("size = ", self.view.bounds.size)
        setPreviewView()
        setShadowView()
        setupScanLine()
        setupDescView()
        animateScanLine()
    }
    
    func setPreviewView() {
        previewView.session = captureSession
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.view.addSubview(previewView)
        previewView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        previewView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        previewView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setShadowView() {
        let shadowView = UIImageView(frame: view.bounds)
        let innerRect = scannerRect()
        
        UIGraphicsBeginImageContext(shadowView.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        var drawRect = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        context.fill(drawRect)
        drawRect = CGRect(x: innerRect.origin.x, y: innerRect.origin.y, width: innerRect.size.width, height: innerRect.size.height)
        context.clear(drawRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        shadowView.image = image
        
        self.view.addSubview(shadowView)
    }
    
    func setupScanLine() {
        let rect = scannerRect()
        let imageSize: CGFloat = 18.0
        let imageX = rect.origin.x
        let imageY = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height + 2
        
        /// 四个边角
        let tlImageView = UIImageView(frame: CGRect(x: imageX, y: imageY, width: imageSize, height: imageSize))
        tlImageView.image = UIImage(named: "scan_tl")
        view.addSubview(tlImageView)
        
        let trImageView = UIImageView(frame: CGRect(x: imageX + width - imageSize, y: imageY, width: imageSize, height: imageSize))
        trImageView.image = UIImage(named: "scan_tr")
        view.addSubview(trImageView)
        
        let blImageView = UIImageView(frame: CGRect(x: imageX, y: imageY + height - imageSize, width: imageSize, height: imageSize))
        blImageView.image = UIImage(named: "scan_bl")
        view.addSubview(blImageView)
        
        let brImageView = UIImageView(frame: CGRect(x: imageX + width - imageSize, y: imageY + height - imageSize, width: imageSize, height: imageSize))
        brImageView.image = UIImage(named: "scan_br")
        view.addSubview(brImageView)
        
        scanLine = UIImageView(frame: CGRect(x: imageX, y: imageY, width: width, height: 2))
        scanLine.image = UIImage(named: "scan_line")
        self.view.addSubview(scanLine)
        
//        self.view.addSubview(activityIndicator)
//        activityIndicator.center = CGPoint(x: rect.midX, y: rect.midY)
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.startAnimating()
    }
    
    func setupDescView() {
        let rect = scannerRect()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.text = "将二维码放入框内，即可自动扫描"
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: rect.origin.y - 37, width: screenWidth, height: 17)
        view.addSubview(label)
    }
    
    func animateScanLine() {
        let rect = scannerRect()
        
        let imageX = rect.origin.x
        let imageY = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height
        let frame = CGRect(x: imageX, y: imageY, width: width, height: 2)
        
        scanLine.frame = frame
        UIView.animate(withDuration: 1.5, delay: 0, options: UIView.AnimationOptions.repeat, animations: { [weak self] in
            self?.scanLine.frame = frame.offsetBy(dx: 0, dy: height)
            }, completion: nil)
    }
}

// MARK: - Help
private extension ScanCodeCtrlr {
    func observedNotification() {
        
    }
    
    func scannerRect() -> CGRect {
        let x: CGFloat = 50.0
        let width = screenWidth - 2 * x
        let y = (screenHeight - width)/2
        
        return CGRect(x: x, y: y, width: width, height: width)
    }
    
    func captureRect() -> CGRect {
        let rect = scannerRect()
        let x = rect.origin.x / screenWidth
        let width = rect.size.width / screenWidth
        return CGRect(x: x, y: 0, width: width, height: 1.0)
    }
}


// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanCodeCtrlr: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let code = readableObject.stringValue else { return }
        
        print("code = ", code)
    }
}
