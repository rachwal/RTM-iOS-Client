//  Copyright (c) 2015-2016. Bartosz Rachwal. The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.

import CoreData

@objc protocol Persistency {

    var context: NSManagedObjectContext? { get }

    func getValues(field: String) -> [AnyObject]
}

