//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import Foundation

class RTMApiClient: NSObject, ApiClient {

    var requestFactory: RequestFactory!
    var methods: Methods!
    var client: WebClient!
    var session: Session!

    func checkConnection(completion: (String?) -> Void) {

        if let request = requestFactory.createGet(methods.status) {

            client.send(request, timeout: 2.0, callback: {
                result, error in
                if let data = result as? NSData {
                    do
                    {
                        let parsedResult: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                        if let parsedTime = parsedResult as? String {
                            completion(parsedTime)
                        }
                    }
                    catch
                    {
                        completion(nil)
                    }

                } else {
                    completion(nil)
                }
            })
        } else {
            completion(nil)
        }
    }

    func postImage(value: NSString, completion: (String?) -> Void) {
        if let request = requestFactory.createPost(methods.images, jsonBody: ["data": value]) {
            client.send(request, timeout: 10.0, callback: {
                result, error in
                if error != nil {
                    completion(nil)
                } else {
                    completion("ok")
                }
            })
        } else {
            completion(nil)
        }
    }
}