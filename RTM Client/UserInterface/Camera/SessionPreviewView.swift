//
//  SessionPreview.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import UIKit
import AVFoundation

class SessionPreviewView: UIView {

    private var previewLayer: AVCaptureVideoPreviewLayer {
        get {
            return self.layer as! AVCaptureVideoPreviewLayer
        }
    }

    var session: AVCaptureSession? {
        get {
            return previewLayer.session
        }
        set(session) {
            previewLayer.session = session
        }
    }

    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
