//
//  RTSearchResult.swift
//  CAD
//
//  Created by Samir Chaves on 12/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

struct RTSearchResult: Hashable {
    enum ResultType {
        case occurrence, team
    }

    let occurrence: SimpleOccurrence?
    let team: NonCriticalTeam?
    let type: ResultType
    let matchedField: String
    let fieldValue: String
    let range: NSRange

    init(occurrence: SimpleOccurrence,
         matchedField: String,
         fieldValue: String,
         range: NSRange) {
        self.occurrence = occurrence
        self.team = nil
        self.matchedField = matchedField
        self.fieldValue = fieldValue
        self.range = range
        type = .occurrence
    }

    init(team: NonCriticalTeam,
         matchedField: String,
         fieldValue: String,
         range: NSRange) {
        self.team = team
        self.occurrence = nil
        self.matchedField = matchedField
        self.fieldValue = fieldValue
        self.range = range
        type = .team
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(occurrence?.id ?? team?.id ?? UUID())
    }

    public static func == (lhs: RTSearchResult, rhs: RTSearchResult) -> Bool {
        if let leftOccurrence = lhs.occurrence,
           let rightOccurrence = rhs.occurrence {
            return leftOccurrence.id == rightOccurrence.id
        }

        if let leftTeam = lhs.team,
           let rightTeam = rhs.team {
            return leftTeam.id == rightTeam.id
        }

        return false
    }
}
