//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import UIKit
import AVFoundation

@objc protocol ImageFactory {
    func create(buffer: CMSampleBuffer) -> UIImage
}

class RTMImageFactory: NSObject, ImageFactory {
    func create(buffer: CMSampleBuffer) -> UIImage {

        let imageBuffer = CMSampleBufferGetImageBuffer(buffer)
        CVPixelBufferLockBaseAddress(imageBuffer!, 0)

        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        let bytesPerPixel = 8
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue) as UInt32)

        let context = CGBitmapContextCreate(baseAddress, width, height, bytesPerPixel, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        let bitmap = CGBitmapContextCreateImage(context);

        CVPixelBufferUnlockBaseAddress(imageBuffer!, 0)

        let image = UIImage(CGImage: bitmap!)
        return image
    }
}
