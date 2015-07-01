//
//  Camera.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import AVFoundation

@objc protocol Camera {

    var session: AVCaptureSession? { get set }

    func initialize()

    func beginSession()

    func endSession()

    var newFrame: (() -> Void)? { get set }

    func start()

    func stop()

    func setCamera(preferredPosition: AVCaptureDevicePosition)

    func setPreset(preset: String)

    func checkAuthorizationStatus(completion: (Bool) -> Void)
}
