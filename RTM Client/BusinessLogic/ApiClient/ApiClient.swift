//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import Foundation

@objc protocol ApiClient {

    func checkConnection(completion: (String?) -> Void)

    func postImage(value: NSString, completion: (String?) -> Void)
}