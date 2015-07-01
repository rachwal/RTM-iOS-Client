//
//  ApplicationAssembly.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import Typhoon

class ApplicationAssembly: TyphoonAssembly {

    var coreComponents: CoreComponents!

    dynamic func cameraViewController() -> AnyObject {
        return TyphoonDefinition.withClass(CameraViewController.self) {
            (definition) in
            definition.injectProperty("configuration", with: self.coreComponents.configuration())
            definition.injectProperty("camera", with: self.coreComponents.camera())
        }
    }

    dynamic func settingsViewController() -> AnyObject {
        return TyphoonDefinition.withClass(SettingsViewController.self) {
            (definition) in
            definition.injectProperty("configuration", with: self.coreComponents.configuration())
            definition.injectProperty("camera", with: self.coreComponents.camera())
            definition.injectProperty("client", with: self.coreComponents.apiClient())
        }
    }
}