//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import Typhoon

class ApplicationAssembly: TyphoonAssembly {

    var coreComponents: CoreComponents!

    dynamic func cameraViewController() -> AnyObject {
        return TyphoonDefinition.withClass(CameraViewController.self) {
            (definition) in
            definition.injectProperty(#selector(CoreComponents.configuration), with: self.coreComponents.configuration())
            definition.injectProperty(#selector(CoreComponents.camera), with: self.coreComponents.camera())
        }
    }

    dynamic func settingsViewController() -> AnyObject {
        return TyphoonDefinition.withClass(SettingsViewController.self) {
            (definition) in
            definition.injectProperty(#selector(CoreComponents.configuration), with: self.coreComponents.configuration())
            definition.injectProperty(#selector(CoreComponents.camera), with: self.coreComponents.camera())
            definition.injectProperty(Selector("client"), with: self.coreComponents.apiClient())
        }
    }
}