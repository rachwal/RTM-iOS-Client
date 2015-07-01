//
//  WebClient.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import Foundation

@objc public protocol WebClient {
    func send(request: NSURLRequest, timeout: NSTimeInterval, callback: (result:AnyObject!, error:NSError?) -> Void) -> NSURLSessionDataTask
}

public class WebClientImpl: NSObject, WebClient {
    public var session: Session!

    @objc public func send(request: NSURLRequest, timeout: NSTimeInterval, callback: (result:AnyObject!, error:NSError?) -> Void) -> NSURLSessionDataTask {
        session.setTimeout(timeout)
        let task = session.dataTaskWithRequest(request) {
            data, response, taskError in
            if (taskError != nil) {
                self.session.setTimeout(10)
                callback(result: data, error: taskError)
            } else {
                self.session.setTimeout(10)
                callback(result: data, error: nil)
            }
        }
        task.resume()
        return task
    }
}
