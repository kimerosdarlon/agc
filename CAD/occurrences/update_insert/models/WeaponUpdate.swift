//
//  WeaponUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 13/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct WeaponUpdate: OccurrenceObjectUpdate {
    typealias ObjectType = WeaponInsert

    let teamId: UUID
    var weapons: [IdVersion]
    let externalId: UUID?
    let newExternalId: UUID?
    var caliber: String?
    var destination: String?
    var specie: String?
    var manufacture: String?
    var brand: String?
    var model: String?
    var serialNumber: String?
    var sinarmSigmaNumber: String?
    var note: String?
    var `type`: String?
    var bondWithInvolved: String?
    var mergeExternalIds: [UUID]?

    func toInsert(objectSituations: [ObjectSituation]) -> WeaponInsert {
        WeaponInsert(
            natureSituation: objectSituations,
            teamId: teamId,
            externalId: externalId ?? UUID(),
            caliber: caliber,
            destination: destination,
            specie: specie,
            manufacture: manufacture,
            brand: brand,
            model: model,
            serialNumber: serialNumber,
            sinarmSigmaNumber: sinarmSigmaNumber,
            note: note,
            type: type,
            bondWithInvolved: bondWithInvolved
        )
    }
}
