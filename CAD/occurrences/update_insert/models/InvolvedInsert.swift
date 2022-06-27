//
//  Involved.swift
//  CAD
//
//  Created by Samir Chaves on 13/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct InvolvedInsert: OccurrenceObjectInsert {
    let externalId: UUID
    let teamId: UUID
    let natureInvolvement: [NatureInvolvement]
    let birthDate: String?
    let age: String?
    let name: String?
    let motherName: String?
    let warrantNumber: String?
    let colorRace: String?
    let gender: String?
    let organInitials: String?
    let documentNumber: String?
    let documentType: String?
    let note: String?
}
