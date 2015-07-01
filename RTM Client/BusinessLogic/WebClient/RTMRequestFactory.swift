//
//  RTMRequestFactory.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import Foundation

public class RTMRequestFactory: NSObject, RequestFactory {
    var configuration: Configuration!

    @objc public func createGet(method: String) -> NSURLRequest? {
        let urlString = configuration.baseURL + method
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            return request
        }
        return nil
    }

    func createPost(method: String, jsonBody: [String:AnyObject]) -> NSURLRequest? {
        let urlString = configuration.baseURL + method
        if let url = NSURL(string: urlString) {
            let request = NSMutableURLRequest(URL: url)
            var jsonifyError: NSError? = nil

            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
            return request
        }
        return nil
    }
}
