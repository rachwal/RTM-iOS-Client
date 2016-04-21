//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import UIKit
import AVFoundation
import AssetsLibrary

class CameraViewController: UIViewController {

    var camera: Camera!
    var configuration: Configuration!

    @IBOutlet weak var previewView: SessionPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()

        camera.initialize()

        previewView.session = camera.session
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setToolbarHidden(true, animated: false)

        camera.beginSession()

    }

    override func viewWillLayoutSubviews() {
        if let preview = self.previewView.layer as? AVCaptureVideoPreviewLayer {
            if let connection = preview.connection {
                connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
            }
        }
    }
}