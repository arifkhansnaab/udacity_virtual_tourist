//
//  MapPin.swift
//  Virtual Tourist v2
//
//  Created by Arif Khan on 10/5/16.
//  Copyright © 2016 Snnab. All rights reserved.
//

import Foundation
import CoreData

class MapPin: NSManagedObject {
    
     convenience init(lat: Double, long: Double,  context : NSManagedObjectContext){
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "MapPin",
                                                in: context){
            self.init(entity: ent, insertInto: context)
            self.latitude = lat as NSNumber?
            self.longitude = long as NSNumber?
        }
        else {
            fatalError("Unable to find Entity MapPin!")
        }
    }
    
}
