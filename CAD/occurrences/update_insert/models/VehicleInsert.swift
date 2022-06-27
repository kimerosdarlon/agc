//
//  VehicleInsert.swift
//  CAD
//
//  Created by Samir Chaves on 13/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct VehicleInsert: OccurrenceObjectInsert {
    let natureInvolvement: [NatureInvolvement]
    let teamId: UUID
    let externalId: UUID
    let characteristics: String?
    let chassis: String?
    let moveCondition: String?
    let color: String?
    let escaped: String?
    let brand: String?
    let model: String?
    let plate: String?
    let restriction: String?
    let robberyTheft: String?
    let `type`: String?
    let note: String?
    let bondWithInvolved: String?
}
