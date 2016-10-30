//
//  Photos+CoreDataClass.swift
//  Virtual Tourist v2
//
//  Created by Arif Khan on 10/29/16.
//  Copyright © 2016 Snnab. All rights reserved.
//

import Foundation
import CoreData


public class Photos: NSManagedObject {
    
    convenience init(image: NSData, url: String,  context : NSManagedObjectContext){
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photos",
                                                in: context){
            self.init(entity: ent, insertInto: context)
            self.image = image
            self.url = url
            
        }
        else {
            fatalError("Unable to find Entity Photo!")
        }
    }


}
