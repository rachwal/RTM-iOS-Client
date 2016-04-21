//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import Foundation

@objc public protocol Session {
    func setTimeout(timeout: NSTimeInterval)

    func dataTaskWithRequest(request: NSURLRequest, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionDataTask
}

public class SessionImpl: NSObject, Session {
    private var session: NSURLSession!

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    public func setTimeout(timeout: NSTimeInterval) {
        session.configuration.timeoutIntervalForRequest = timeout
    }

    @objc public func dataTaskWithRequest(request: NSURLRequest, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionDataTask {
        return session.dataTaskWithRequest(request, completionHandler: completionHandler!)
    }
}