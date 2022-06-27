//
//  InvolvedUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 13/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct InvolvedUpdate: OccurrenceObjectUpdate {
    typealias ObjectType = InvolvedInsert

    var externalId: UUID?
    let teamId: UUID
    var involved: [IdVersion]
    var newExternalId: UUID?
    var birthDate: String?
    var age: String?
    var name: String?
    var motherName: String?
    var warrantNumber: String?
    var colorRace: String?
    var gender: String?
    var organInitials: String?
    var documentNumber: String?
    var documentType: String?
    var note: String?
    var mergeExternalIds: [UUID]?

    func toInsert(naturesAndInvolvements: [NatureInvolvement]) -> InvolvedInsert {
        InvolvedInsert(
            externalId: externalId ?? UUID(),
            teamId: teamId,
            natureInvolvement: naturesAndInvolvements,
            birthDate: birthDate,
            age: age,
            name: name,
            motherName: motherName,
            warrantNumber: warrantNumber,
            colorRace: colorRace,
            gender: gender,
            organInitials: organInitials,
            documentNumber: documentNumber,
            documentType: documentType,
            note: note
        )
    }
}
