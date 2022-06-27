//
//  DrugUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 13/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct DrugUpdate: OccurrenceObjectUpdate {
    typealias ObjectType = DrugInsert

    let teamId: UUID
    var drugs: [IdVersion]
    var externalId: UUID?
    var newExternalId: UUID?
    var destination: String?
    var `package`: String?
    var note: String?
    var quantity: String?
    var apparentType: String?
    var measureUnit: String?
    var bondWithInvolved: String?
    var mergeExternalIds: [UUID]?

    func toInsert(objectSituations: [ObjectSituation]) -> DrugInsert {
        DrugInsert(
            teamId: teamId,
            natureSituation: objectSituations,
            externalId: externalId ?? UUID(),
            destination: destination,
            package: `package`,
            note: note,
            quantity: quantity,
            apparentType: apparentType,
            measureUnit: measureUnit,
            bondWithInvolved: bondWithInvolved
        )
    }
}
