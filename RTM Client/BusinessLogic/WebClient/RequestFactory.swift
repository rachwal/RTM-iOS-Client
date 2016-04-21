//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import Foundation

@objc protocol RequestFactory {

    func createGet(method: String) -> NSURLRequest?

    func createPost(method: String, jsonBody: [String:AnyObject]) -> NSURLRequest?
}