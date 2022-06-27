//
//  CDRecents+CoreDataProperties.swift
//  
//
//  Created by Ramires Moreira on 25/05/20.
//
//

import Foundation
import CoreData

extension CDRecents {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDRecents> {
        return NSFetchRequest<CDRecents>(entityName: "CDRecents")
    }

    @NSManaged public var date: Date?
    @NSManaged public var formattedDate: String?
    @NSManaged public var iconName: String?
    @NSManaged public var module: String?
    @NSManaged public var text: String?

}
