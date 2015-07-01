//
//  ImageFactory.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol ImageFactory {
    func create(buffer: CMSampleBuffer) -> UIImage
}

class RTMImageFactory: NSObject, ImageFactory {
    func create(buffer: CMSampleBuffer) -> UIImage {

        var imageBuffer = CMSampleBufferGetImageBuffer(buffer)
        CVPixelBufferLockBaseAddress(imageBuffer, 0)

        var baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        var bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        var bytesPerPixel = 8
        var width = CVPixelBufferGetWidth(imageBuffer)
        var height = CVPixelBufferGetHeight(imageBuffer)
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGBitmapInfo((CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue) as UInt32)

        var context = CGBitmapContextCreate(baseAddress, width, height, bytesPerPixel, bytesPerRow, colorSpace, bitmapInfo)
        var bitmap = CGBitmapContextCreateImage(context);

        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)

        var image = UIImage(CGImage: bitmap)
        return image!
    }
}
