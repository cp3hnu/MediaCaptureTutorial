//
//  FrameExtractionCtrlr.swift
//  MediaCaptureTutorial
//
//  Created by cp3hnu on 2021/12/23.
//

import UIKit
import AVFoundation

final class FrameExtractionCtrlr: UIViewController {
    
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let captureSession = AVCaptureSession()
    private let context = CIContext()
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.title = "提取视频帧"
        self.view.backgroundColor = UIColor.white
        setupView()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    deinit {
        // print("FrameExtractionCtrlr")
    }
}

// MARK: - Private
private extension FrameExtractionCtrlr {
    func setupView() {
        self.view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: Sample buffer to UIImage conversion
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Configure Session
private extension FrameExtractionCtrlr {
    func configureSession() {
        captureSession.sessionPreset = .medium
        guard let captureDevice = selectFrontCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(with: AVMediaType.video) else { return }
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = true
        }
    }
    
    func selectFrontCaptureDevice() -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .builtInTrueDepthCamera,
            .builtInTelephotoCamera,
            .builtInUltraWideCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,
            .builtInTripleCamera
        ]
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .front)
        return discoverySession.devices.first
    }
}


// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension FrameExtractionCtrlr: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
     //   print("get frame")
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async {
            self.imageView.image = uiImage
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("drop frame")
    }
}
