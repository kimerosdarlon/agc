//
//  CDState+CoreDataProperties.swift
//  
//
//  Created by Ramires Moreira on 25/05/20.
//
//

import Foundation
import CoreData

extension CDState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDState> {
        return NSFetchRequest<CDState>(entityName: "CDState")
    }

    @NSManaged public var initials: String?
    @NSManaged public var name: String?
    @NSManaged public var cities: NSSet?

}

// MARK: Generated accessors for cities
extension CDState {

    @objc(addCitiesObject:)
    @NSManaged public func addToCities(_ value: CDCity)

    @objc(removeCitiesObject:)
    @NSManaged public func removeFromCities(_ value: CDCity)

    @objc(addCities:)
    @NSManaged public func addToCities(_ values: NSSet)

    @objc(removeCities:)
    @NSManaged public func removeFromCities(_ values: NSSet)

}
