//
//  VehicleUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct VehicleUpdate: OccurrenceObjectUpdate {
    typealias ObjectType = VehicleInsert

    var teamId: UUID
    var vehicles: [IdVersion]
    var externalId: UUID?
    var newExternalId: UUID?
    var characteristics: String?
    var chassis: String?
    var moveCondition: String?
    var color: String?
    var escaped: String?
    var brand: String?
    var model: String?
    var plate: String?
    var restriction: String?
    var robberyTheft: String?
    var `type`: String?
    var note: String?
    var bondWithInvolved: String?
    var mergeExternalIds: [UUID]?

    func toInsert(naturesAndInvolvements: [NatureInvolvement]) -> VehicleInsert {
        VehicleInsert(
            natureInvolvement: naturesAndInvolvements,
            teamId: teamId,
            externalId: externalId ?? UUID(),
            characteristics: characteristics,
            chassis: chassis,
            moveCondition: moveCondition,
            color: color,
            escaped: escaped,
            brand: brand,
            model: model,
            plate: plate,
            restriction: restriction,
            robberyTheft: robberyTheft,
            type: type,
            note: note,
            bondWithInvolved: bondWithInvolved
        )
    }
}
