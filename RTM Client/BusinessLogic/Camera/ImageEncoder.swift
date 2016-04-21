//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import UIKit
import AVFoundation

@objc protocol ImageEncoder {
    func encode(buffer: CMSampleBuffer) -> String
}

class RTMImageEncoder: NSObject, ImageEncoder {
    var factory: ImageFactory!
    var configuration: Configuration!

    func encode(buffer: CMSampleBuffer) -> String {

        let image = factory.create(buffer)
        let imageData = UIImageJPEGRepresentation(image, getCompression(configuration.videoQuality))
        return imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
    }

    private func getCompression(qualityIndex: Int) -> CGFloat {
        if qualityIndex == 0 {
            return 0.25
        }
        if qualityIndex == 1 {
            return 0.5
        }
        if qualityIndex == 2 {
            return 0.75
        }
        return 0.5
    }
}