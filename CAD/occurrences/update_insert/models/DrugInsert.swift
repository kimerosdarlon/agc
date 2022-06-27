//
//  DrugInsert.swift
//  CAD
//
//  Created by Samir Chaves on 13/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct DrugInsert: OccurrenceObjectInsert {
    let teamId: UUID
    let natureSituation: [ObjectSituation]
    let externalId: UUID
    let destination: String?
    let `package`: String?
    let note: String?
    let quantity: String?
    let apparentType: String?
    let measureUnit: String?
    let bondWithInvolved: String?
}
