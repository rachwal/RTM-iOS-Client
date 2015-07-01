//
//  Persistency.swift
//  RTM Client
//
//  Created by Bartosz Rachwal on 7/1/15.
//  Copyright (c) 2015 The National Institute of Advanced Industrial Science and Technology, Japan. All rights reserved.
//

import CoreData

@objc protocol Persistency {

    var context: NSManagedObjectContext? { get }

    func getValues(field: String) -> [AnyObject]
}

