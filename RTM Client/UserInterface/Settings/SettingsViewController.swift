//
//  SettingsViewController.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsViewController: UITableViewController, UITextFieldDelegate {

    var configuration: Configuration!
    var camera: Camera!
    var client: ApiClient!

    @IBOutlet weak var streamingSwitch: UISwitch!
    @IBOutlet weak var backCameraSwitch: UISwitch!
    @IBOutlet weak var frontCameraSwitch: UISwitch!

    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var portField: UITextField!

    var activeField: UITextField?

    @IBOutlet weak var videoSizeSelector: UISegmentedControl!
    @IBOutlet weak var videoQualitySelector: UISegmentedControl!

    override func viewDidLoad() {
        hostField.delegate = self
        portField.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateStreamingSwitch", name: "RTMClient.StreamingChanged", object: nil)

        initFields()
    }

    func initFields() {
        streamingSwitch.on = configuration.streaming

        updateFrontCameraSwitch()
        updateBackCameraSwitch()

        videoSizeSelector.selectedSegmentIndex = configuration.presetIndex
        videoQualitySelector.selectedSegmentIndex = configuration.videoQuality

        hostField.text = configuration.host
        portField.text = "\(configuration.port)"

        activeField = portField
    }

    func updateStreamingSwitch() {
        if configuration.streaming {
            dispatch_async(dispatch_get_main_queue()) {
                self.streamingSwitch.setOn(true, animated: true)
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.streamingSwitch.setOn(false, animated: true)
            }
        }
    }

    func updateFrontCameraSwitch() {
        if configuration.captureDevicePosition == .Front {
            dispatch_async(dispatch_get_main_queue()) {
                self.frontCameraSwitch.setOn(true, animated: true)
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.frontCameraSwitch.setOn(false, animated: true)
            }
        }
    }

    func updateBackCameraSwitch() {
        if configuration.captureDevicePosition == .Back {
            dispatch_async(dispatch_get_main_queue()) {
                self.backCameraSwitch.setOn(true, animated: true)
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.backCameraSwitch.setOn(false, animated: true)
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func sendStreamChange(sender: UISwitch) {

        if sender.on {
            client.checkConnection() {
                message in
                if let statusOk = message {
                    self.camera.start()
                    self.configuration.streaming = true
                } else {
                    self.displayNoConnectionPopup()
                }
            }
        } else {
            camera.stop()
        }
    }

    private func displayNoConnectionPopup() {
        dispatch_async(dispatch_get_main_queue()) {
            self.streamingSwitch.setOn(false, animated: true)
            var popup: UIAlertController = UIAlertController(title: "No Connection", message: "Please check WiFi status, host address and port settings.", preferredStyle: UIAlertControllerStyle.Alert)
            var action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            popup.addAction(action)
            self.presentViewController(popup, animated: true, completion: nil)
        }
    }

    @IBAction func hostAddressChanged(sender: UITextField) {
        configuration.host = sender.text
    }

    @IBAction func portNumberChanged(sender: UITextField) {
        var correctValue = false
        if let newPort = sender.text.toInt() {
            if newPort > 0 && newPort < 65536 {
                correctValue = true
                configuration.port = newPort
            }
        }
        if !correctValue {
            dispatch_async(dispatch_get_main_queue()) {
                var popup: UIAlertController = UIAlertController(title: "Incorrect value", message: "Port value should be an integer greater than than zero up to a value of 65535", preferredStyle: UIAlertControllerStyle.Alert)
                var action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                popup.addAction(action)
                self.presentViewController(popup, animated: true) {
                    self.portField.text = "\(self.configuration.port)"
                }
            }
        }
    }

    @IBAction func videoSizeChanged(sender: UISegmentedControl) {
        configuration.presetIndex = sender.selectedSegmentIndex
        camera.setPreset(configuration.preset)
    }

    @IBAction func videoQualityChanged(sender: UISegmentedControl) {
        configuration.videoQuality = sender.selectedSegmentIndex
    }

    @IBAction func toggleFrontCamera(sender: AnyObject) {
        if frontCameraSwitch.on {
            configuration.captureDevicePosition = AVCaptureDevicePosition.Front
        } else {
            configuration.captureDevicePosition = AVCaptureDevicePosition.Back
        }
        udateCameraSwitches(configuration.captureDevicePosition)
        camera.setCamera(configuration.captureDevicePosition)
    }

    @IBAction func toggleBackCamera(sender: AnyObject) {
        if backCameraSwitch.on {
            configuration.captureDevicePosition = AVCaptureDevicePosition.Back
        } else {
            configuration.captureDevicePosition = AVCaptureDevicePosition.Front
        }
        udateCameraSwitches(configuration.captureDevicePosition)
        camera.setCamera(configuration.captureDevicePosition)
    }

    func udateCameraSwitches(position: AVCaptureDevicePosition) {
        updateBackCameraSwitch()
        updateFrontCameraSwitch()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(false)
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }

    func keyboardDidShow(notification: NSNotification) {

        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        var contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.height + 10, 0.0)

        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets

        var rect = self.view.frame
        rect.size.height -= keyboardFrame.height

        if (!CGRectContainsPoint(rect, activeField!.frame.origin)) {
            self.tableView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        var contentInsets = UIEdgeInsetsZero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
}