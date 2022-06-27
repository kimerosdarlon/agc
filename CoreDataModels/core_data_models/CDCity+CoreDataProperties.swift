//
//  CDCity+CoreDataProperties.swift
//  
//
//  Created by Ramires Moreira on 25/05/20.
//
//

import Foundation
import CoreData

extension CDCity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCity> {
        return NSFetchRequest<CDCity>(entityName: "CDCity")
    }

    @NSManaged public var code: Int32
    @NSManaged public var name: String?

}
