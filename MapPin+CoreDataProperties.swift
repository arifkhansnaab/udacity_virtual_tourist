//
//  MapPin+CoreDataProperties.swift
//  Virtual Tourist v2
//
//  Created by Arif Khan on 10/10/16.
//  Copyright © 2016 Snnab. All rights reserved.
//

import Foundation
import CoreData
 

extension MapPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapPin> {
        return NSFetchRequest<MapPin>(entityName: "MapPin");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension MapPin {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photos)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photos)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
