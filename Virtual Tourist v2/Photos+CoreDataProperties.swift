//
//  Photos+CoreDataProperties.swift
//  Virtual Tourist v2
//
//  Created by Arif Khan on 10/29/16.
//  Copyright © 2016 Snnab. All rights reserved.
//

import Foundation
import CoreData
 

extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var url: String?
    @NSManaged public var mapPin: MapPin?

}
