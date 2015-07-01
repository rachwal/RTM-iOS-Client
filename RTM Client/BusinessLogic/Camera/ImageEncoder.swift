//
//  ImageEncoder.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol ImageEncoder {
    func encode(buffer: CMSampleBuffer) -> String
}

class RTMImageEncoder: NSObject, ImageEncoder {
    var factory: ImageFactory!
    var configuration: Configuration!

    func encode(buffer: CMSampleBuffer) -> String {

        var image = factory.create(buffer)
        var imageData = UIImageJPEGRepresentation(image, getCompression(configuration.videoQuality))
        return imageData.base64EncodedStringWithOptions(.allZeros)
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