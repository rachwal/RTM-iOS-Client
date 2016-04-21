//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

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
     
            do{
                request.HTTPMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions())
                return request
            }
            catch
            {
                return nil
            }
        }
        return nil
    }
}
