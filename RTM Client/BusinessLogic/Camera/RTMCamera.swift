//
//  RTMCamera.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import UIKit
import AVFoundation

class RTMCamera: NSObject, Camera, AVCaptureVideoDataOutputSampleBufferDelegate {

    var client: ApiClient!
    var configuration: Configuration!
    var imageEncoder: ImageEncoder!
    var session: AVCaptureSession?

    var newFrame: (() -> Void)?

    private var SessionRunningAndDeviceAuthorizedContext = "SessionRunningAndDeviceAuthorizedContext"
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var sessionQueue: dispatch_queue_t?
    private var runtimeErrorHandlingObserver: AnyObject?
    private var canSend = true

    override init() {
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
        self.session = AVCaptureSession()
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startStreaming", name: "RTMClient.DidBecomeActive", object: nil)
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {

        if !canSend || !configuration.streaming {
            return
        }

        let encodedImage = imageEncoder.encode(sampleBuffer)

        canSend = false

        self.client.postImage(encodedImage) {
            response in
            if let statusOk = response {
                if let handler = self.newFrame {
                    dispatch_async(dispatch_get_main_queue()) {
                        handler()
                    }
                }
                self.canSend = true
            } else {
                self.stop()
            }
        }
    }

    func initialize() {
        checkAuthorizationStatus({
            status in
            if status {
                dispatch_async(self.sessionQueue!, {
                    if let videoDevice: AVCaptureDevice = self.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: self.configuration.captureDevicePosition) {
                        self.session?.beginConfiguration()
                        self.session?.sessionPreset = self.configuration.preset

                        var devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

                        self.setFocusAndExposure(AVCaptureFocusMode.ContinuousAutoFocus, exposureMode: AVCaptureExposureMode.ContinuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)

                        var error: NSError? = nil

                        var videoDeviceInput: AVCaptureDeviceInput? = AVCaptureDeviceInput(device: videoDevice, error: &error)

                        if (error != nil) {
                            println(error)
                        }

                        if self.session!.canAddInput(videoDeviceInput) {
                            self.session!.addInput(videoDeviceInput)
                            self.videoDeviceInput = videoDeviceInput
                        }

                        var videoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
                        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
                        videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                        videoDataOutput.alwaysDiscardsLateVideoFrames = true

                        if (self.session!.canAddOutput(videoDataOutput)) {
                            self.session!.addOutput(videoDataOutput)
                        }

                        self.session?.commitConfiguration()
                    }
                })
            }
        })
    }

    private func deviceWithMediaType(mediaType: String, preferringPosition: AVCaptureDevicePosition) -> AVCaptureDevice? {

        var devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var selectedDevice: AVCaptureDevice? = nil
        if let captureDevice: AVCaptureDevice = devices.first as? AVCaptureDevice {
            for device in devices {
                if device.position == preferringPosition {
                    selectedDevice = device as? AVCaptureDevice
                    break
                }
            }
        }
        return selectedDevice
    }

    func beginSession() {
        if let sessionQ = sessionQueue {
            dispatch_async(sessionQ, {
                self.addObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", options: NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New, context: &self.SessionRunningAndDeviceAuthorizedContext)

                NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput?.device)

                self.runtimeErrorHandlingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: self.session, queue: nil, usingBlock: {
                    (note: NSNotification?) in
                    dispatch_async(sessionQ, {
                        if let sess = self.session {
                            sess.startRunning()
                        }
                    })
                })
                self.session?.startRunning()
            })
        }
    }

    func endSession() {
        if let sessionQ = sessionQueue {
            dispatch_async(sessionQ, {

                if self.session != nil {
                    self.session!.stopRunning()

                    NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput?.device)
                    NSNotificationCenter.defaultCenter().removeObserver(self.runtimeErrorHandlingObserver!)

                    self.removeObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", context: &self.SessionRunningAndDeviceAuthorizedContext)
                }
            })
        }
    }

    func start() {
        canSend = true
    }

    func stop() {
        canSend = false
        configuration.streaming = false
    }

    func startStreaming() {
        if configuration.streaming {
            self.client.checkConnection() {
                message in
                if let statusOk = message {
                    self.start()
                    self.configuration.streaming = true
                } else {
                    self.configuration.streaming = false
                }
            }
        }
    }

    func checkAuthorizationStatus(completion: (Bool) -> Void) {
        var mediaType: String = AVMediaTypeVideo
        AVCaptureDevice.requestAccessForMediaType(mediaType, completionHandler: {
            granted in
            completion(granted)
        })
    }

    func setPreset(preset: String) {

        if let sessionQ = sessionQueue {
            dispatch_async(sessionQ, {

                self.session!.beginConfiguration()

                self.session?.sessionPreset = preset

                self.session!.commitConfiguration()
            })
        }
    }

    func setCamera(preferredPosition: AVCaptureDevicePosition) {

        if let sessionQ = sessionQueue {
            dispatch_async(sessionQ, {

                if self.videoDeviceInput == nil {
                    return
                }

                var currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device

                if let device: AVCaptureDevice = self.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition) {
                    var devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

                    self.setFocusAndExposure(AVCaptureFocusMode.ContinuousAutoFocus, exposureMode: AVCaptureExposureMode.ContinuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)

                    var videoDeviceInput: AVCaptureDeviceInput = AVCaptureDeviceInput(device: device, error: nil)

                    self.session!.beginConfiguration()

                    self.session!.removeInput(self.videoDeviceInput)

                    if self.session!.canAddInput(videoDeviceInput) {

                        self.session!.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput

                    } else {
                        self.session!.addInput(self.videoDeviceInput)
                    }

                    self.session!.commitConfiguration()
                }
            })
        }
    }

    private func setFocusAndExposure(focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(self.sessionQueue!, {
            var device: AVCaptureDevice! = self.videoDeviceInput!.device
            var error: NSError? = nil

            if device.lockForConfiguration(&error) {
                if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusMode = focusMode
                    device.focusPointOfInterest = point
                }
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = exposureMode
                }
                device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } else {
                println(error)
            }
        })
    }
}