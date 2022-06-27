//
//  PositionEventInput+CoreDataProperties.swift
//  CAD
//
//  Created by Samir Chaves on 06/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//
//

import Foundation
import CoreData

extension PositionEventInput {

    @nonobjc public static func fetchRequest() -> NSFetchRequest<PositionEventInput> {
        return NSFetchRequest<PositionEventInput>(entityName: "PositionEventInput")
    }

    @NSManaged public var accuracy: Float
    @NSManaged public var equipmentId: UUID?
    @NSManaged public var deviceId: String
    @NSManaged public var eventTimestamp: Int64
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var teamId: UUID

    func toRecord() -> PositionEventRecord {
        PositionEventRecord(
            teamId: teamId,
            deviceId: deviceId,
            latitude: latitude,
            longitude: longitude,
            eventTimestamp: Int(eventTimestamp),
            accuracy: accuracy,
            equipmentId: equipmentId
        )
    }
}

extension PositionEventInput: Identifiable { }
