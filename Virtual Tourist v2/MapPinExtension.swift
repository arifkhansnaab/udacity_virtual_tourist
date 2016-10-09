//
//  MapPinExtension.swift
//  Virtual Tourist v2
//
//  Created by Arif Khan on 10/5/16.
//  Copyright © 2016 Snnab. All rights reserved.
//

import Foundation
import CoreData

extension MapPin {
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var photos: NSSet?
}
