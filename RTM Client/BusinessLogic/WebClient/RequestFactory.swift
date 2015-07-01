//
//  RequestFactory.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import Foundation

@objc protocol RequestFactory {

    func createGet(method: String) -> NSURLRequest?

    func createPost(method: String, jsonBody: [String:AnyObject]) -> NSURLRequest?
}