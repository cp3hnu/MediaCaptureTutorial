//
//  CapturePreviewView.swift
//  MediaCaptureTutorial
//
//  Created by cp3hnu on 2021/12/23.
//

import UIKit
import AVFoundation

class CapturePreviewView: UIView {
  override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
  
  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    return layer as! AVCaptureVideoPreviewLayer
  }
    
  var session: AVCaptureSession? {
    get {
      return videoPreviewLayer.session
    }
    set {
      videoPreviewLayer.session = newValue
    }
  }
}
