//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RTMCamera.startStreaming), name: "RTMClient.DidBecomeActive", object: nil)
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {

        if !canSend || !configuration.streaming {
            return
        }

        let encodedImage = imageEncoder.encode(sampleBuffer)

        canSend = false

        self.client.postImage(encodedImage) {
            response in
            if response != nil {
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

                        let devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

                        self.setFocusAndExposure(AVCaptureFocusMode.ContinuousAutoFocus, exposureMode: AVCaptureExposureMode.ContinuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)

                        var videoDeviceInput: AVCaptureDeviceInput? = nil;
                        
                        do
                        {
                            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                        }
                        catch
                        {
                            print("RTMCamera::initialize::AVCaptureDeviceInput")
                        }

                        if self.session!.canAddInput(videoDeviceInput) {
                            self.session!.addInput(videoDeviceInput)
                            self.videoDeviceInput = videoDeviceInput
                        }

                        let videoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
                        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)]
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

        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var selectedDevice: AVCaptureDevice? = nil
        if let _: AVCaptureDevice = devices.first as? AVCaptureDevice {
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
                self.addObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", options: [.Old , .New], context: &self.SessionRunningAndDeviceAuthorizedContext)
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
                if message != nil {
                    self.start()
                    self.configuration.streaming = true
                } else {
                    self.configuration.streaming = false
                }
            }
        }
    }

    func checkAuthorizationStatus(completion: (Bool) -> Void) {
        let mediaType: String = AVMediaTypeVideo
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

                if let device: AVCaptureDevice = self.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition) {
                    let devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

                    self.setFocusAndExposure(AVCaptureFocusMode.ContinuousAutoFocus, exposureMode: AVCaptureExposureMode.ContinuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)
                    do
                    {
                        let videoDeviceInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: device)

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
                    catch {
                        return
                    }
                }
            })
        }
    }

    private func setFocusAndExposure(focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(self.sessionQueue!, {
            let device: AVCaptureDevice! = self.videoDeviceInput!.device

            do
            {
                try device.lockForConfiguration()
                
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
            }
            catch
            {
                print("RTMCamera::initialize::AVCaptureDeviceInput")
            }
            
        })
    }
}