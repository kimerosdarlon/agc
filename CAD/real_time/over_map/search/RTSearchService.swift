//
//  RTSearchService.swift
//  CAD
//
//  Created by Samir Chaves on 06/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

class RTSearchService {
    static let shared = RTSearchService()

    private let teamsManager = TeamMembersManager.shared
    private let occurrenceDataSource = RecentOccurrencesDataSource.shared

    func search(by query: String) -> [RTSearchResult] {
        let teamsResults = teamsManager.search(by: query).map { teamResult in
            RTSearchResult(
                team: teamResult.team,
                matchedField: teamResult.field.rawValue,
                fieldValue: teamResult.value,
                range: teamResult.range
            )
        }
        let occurrencesResults = occurrenceDataSource.search(by: query).map { occurrenceResult in
            RTSearchResult(
                occurrence: occurrenceResult.occurrence,
                matchedField: occurrenceResult.field.rawValue,
                fieldValue: occurrenceResult.value,
                range: occurrenceResult.range
            )
        }

        var results = [RTSearchResult]()
        results.append(contentsOf: occurrencesResults)
        results.append(contentsOf: teamsResults)

        return results
    }
}
