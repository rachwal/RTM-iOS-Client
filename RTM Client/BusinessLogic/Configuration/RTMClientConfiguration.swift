//
//  RTMClientConfiguration.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import AVFoundation
import CoreData

public class RTMClientConfiguration: NSObject, Configuration {

    var persistency: Persistency!

    var host: String {
        get {
            return getSerializedValue("Host", attribute: "address", defaultValue: "Enter host address")
        }
        set(address) {
            removeSerializedValue("Host")
            setSerializedValue("Host", attribute: "address", value: address)
        }
    }

    var port: Int {
        get {
            return getSerializedValue("Port", attribute: "number", defaultValue: 9000)
        }
        set(value) {
            removeSerializedValue("Port")
            setSerializedValue("Port", attribute: "number", value: value)
        }
    }

    var baseURL: String {
        get {
            return "http://\(host):\(port)"
        }
    }

    var captureDevicePosition: AVCaptureDevicePosition {
        get {
            return getSerializedValue("Camera", attribute: "device", defaultValue: AVCaptureDevicePosition.Back)
        }
        set(device) {
            removeSerializedValue("Camera")
            setSerializedValue("Camera", attribute: "device", value: device)
        }
    }

    var streaming: Bool = false {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("RTMClient.StreamingChanged", object: nil)
        }
    }

    var preset: String {
        get {
            return getSerializedValue("VideoSize", attribute: "value", defaultValue: "AVCaptureSessionPreset640x480")
        }
        set(name) {
            removeSerializedValue("VideoSize")
            setSerializedValue("VideoSize", attribute: "value", value: name)
        }
    }

    var presetIndex: Int {
        get {
            return cameraPresetIndex(preset)
        }
        set(index) {
            preset = cameraPresetName(index)
        }
    }

    func cameraPresetName(index: Int) -> String {
        if index == 0 {
            return AVCaptureSessionPreset352x288
        }
        if index == 1 {
            return AVCaptureSessionPreset640x480
        }
        if index == 2 {
            return AVCaptureSessionPresetiFrame960x540
        }
        return AVCaptureSessionPresetMedium
    }

    func cameraPresetIndex(name: NSString) -> Int {
        if name.isEqualToString(AVCaptureSessionPreset352x288) {
            return 0
        }
        if name.isEqualToString(AVCaptureSessionPreset640x480) {
            return 1
        }
        if name.isEqualToString(AVCaptureSessionPresetiFrame960x540) {
            return 2
        }
        return 1
    }

    var videoQuality: Int {
        get {
            return getSerializedValue("VideoQuality", attribute: "value", defaultValue: 1)
        }
        set(quality) {
            removeSerializedValue("VideoQuality")
            setSerializedValue("VideoQuality", attribute: "value", value: quality)
        }
    }

    private func getSerializedValue<T>(entity: String, attribute: String, defaultValue: T) -> T {

        let values = persistency.getValues(entity)
        if values.count > 0 {
            if defaultValue is String {
                if let field = values.last!.valueForKey(attribute) as? String {
                    return field as! T
                }
            }
            if defaultValue is Int {
                if let field = values.last!.valueForKey(attribute) as? NSNumber {
                    return field.integerValue as! T
                }
            }
            if defaultValue is AVCaptureDevicePosition {
                if let field = values.last!.valueForKey(attribute) as? NSNumber {
                    switch (field.integerValue) {
                    case 1: return AVCaptureDevicePosition.Back as! T
                    case 2: return AVCaptureDevicePosition.Front as! T
                    default: return AVCaptureDevicePosition.Back as! T
                    }
                }
            }
        }
        return defaultValue
    }

    private func setSerializedValue<T>(entity: String, attribute: String, value: T) {
        if let managedContext = persistency.context {
            let entity = NSEntityDescription.entityForName(entity, inManagedObjectContext: managedContext)
            let selected = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)

            if let stringValue = value as? String {
                selected.setValue(stringValue, forKey: attribute)
            } else if let intValue = value as? Int {
                selected.setValue(NSNumber(integer: intValue), forKey: attribute)
            } else if let devicePosition = value as? AVCaptureDevicePosition {
                selected.setValue(NSNumber(integer: devicePosition.rawValue), forKey: attribute)
            }

            var error: NSError?
            if !managedContext.save(&error) {
                println(error?.userInfo)
            }
        }
    }

    private func removeSerializedValue(entity: String) {
        if let managedContext = persistency.context {
            let request = NSFetchRequest(entityName: entity)

            var error: NSError?

            if let results = managedContext.executeFetchRequest(request, error: &error) {
                for (var i = 0; i < results.count; i++) {
                    managedContext.deleteObject(results[i] as! NSManagedObject)
                }
            }

            if !managedContext.save(&error) {
                println(error?.userInfo)
            }
        }
    }

}

public class ClientMethods: NSObject, Methods {

    var images: String {
        get {
            return "/api/images"
        }
    }

    var status: String {
        get {
            return "/api/status"
        }
    }
}