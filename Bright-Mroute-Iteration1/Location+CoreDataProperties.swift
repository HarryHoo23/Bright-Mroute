//
//  Location+CoreDataProperties.swift
//  
//
//  Created by zhongheng on 4/4/19.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var date: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?

}
