//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import Typhoon

class CoreComponents: TyphoonAssembly {

    internal dynamic func methods() -> AnyObject {
        return TyphoonDefinition.withClass(ClientMethods.self) {
            (definition) in
            definition.scope = TyphoonScope.Singleton
        }
    }

    internal dynamic func session() -> AnyObject {
        return TyphoonDefinition.withClass(SessionImpl.self)
    }

    internal dynamic func persistency() -> AnyObject {
        return TyphoonDefinition.withClass(RTMPersistency.self) {
            (definition) in
            definition.scope = TyphoonScope.Singleton
        }
    }

    internal dynamic func configuration() -> AnyObject {
        return TyphoonDefinition.withClass(RTMClientConfiguration.self) {
            (definition) in
            definition.injectProperty(#selector(CoreComponents.persistency), with: self.persistency())
            definition.scope = TyphoonScope.Singleton
        }
    }

    internal dynamic func imageFactory() -> AnyObject {
        return TyphoonDefinition.withClass(RTMImageFactory.self)
    }

    internal dynamic func imageEncoder() -> AnyObject {
        return TyphoonDefinition.withClass(RTMImageEncoder.self) {
            (definition) in
            definition.injectProperty(#selector(CoreComponents.configuration), with: self.configuration())
            definition.injectProperty(Selector("factory"), with: self.imageFactory())
        }
    }

    internal dynamic func camera() -> AnyObject {
        return TyphoonDefinition.withClass(RTMCamera.self) {
            definition in
            definition.injectProperty(Selector("client"), with: self.apiClient())
            definition.injectProperty(#selector(CoreComponents.configuration), with: self.configuration())
            definition.injectProperty(#selector(CoreComponents.imageEncoder), with: self.imageEncoder())
            definition.scope = TyphoonScope.Singleton
        }
    }

    internal dynamic func requestFactory() -> AnyObject {
        return TyphoonDefinition.withClass(RTMRequestFactory.self)
        {
            (definition) in
            definition.injectProperty(#selector(CoreComponents.configuration), with: self.configuration())
        }
    }

    internal dynamic func webClient() -> AnyObject {
        return TyphoonDefinition.withClass(WebClientImpl.self)
        {
            (definition) in
            definition.injectProperty(#selector(CoreComponents.session), with: self.session())
        }
    }

    internal dynamic func apiClient() -> AnyObject {
        return TyphoonDefinition.withClass(RTMApiClient.self) {
            definition in
            definition.injectProperty(#selector(CoreComponents.requestFactory), with: self.requestFactory())
            definition.injectProperty(#selector(CoreComponents.methods), with: self.methods())
            definition.injectProperty(Selector("client"), with: self.webClient())
        }
    }
}