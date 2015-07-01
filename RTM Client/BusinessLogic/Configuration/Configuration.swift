//
//  Configuration.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import AVFoundation

@objc internal protocol Configuration {

    var host: String { get set }
    var port: Int { get set }
    var baseURL: String { get }
    var captureDevicePosition: AVCaptureDevicePosition { get set }
    var streaming: Bool { get set }
    var preset: String { get set }
    var presetIndex: Int { get set }
    func cameraPresetName(index: Int) -> String

    func cameraPresetIndex(name: NSString) -> Int
    var videoQuality: Int { get set }
}

@objc internal protocol Methods {
    var images: String { get }
    var status: String { get }
}

