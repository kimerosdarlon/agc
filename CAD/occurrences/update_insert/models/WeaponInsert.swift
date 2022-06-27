//
//  WeaponInsert.swift
//  CAD
//
//  Created by Samir Chaves on 13/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct WeaponInsert: OccurrenceObjectInsert {
    let natureSituation: [ObjectSituation]
    let teamId: UUID
    let externalId: UUID
    let caliber: String?
    let destination: String?
    let specie: String?
    let manufacture: String?
    let brand: String?
    let model: String?
    let serialNumber: String?
    let sinarmSigmaNumber: String?
    let note: String?
    let `type`: String?
    let bondWithInvolved: String?
}
