//
//  OccurrenceNaturesUpdate+fields.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

extension OccurrenceNaturesUpdate {
    internal func searchMatch(query: NSRegularExpression, with term: String) -> NSRange? {
        let foldedTerm = term.prepareForSearch()
        let range = NSRange(location: 0, length: foldedTerm.utf16.count)
        return query.firstMatch(in: foldedTerm, options: [], range: range)?.range
    }

    internal func setupNaturesField() {
        naturesField?.onChangeQuery = { query, completion in
            let natures = self.dataSource.natures
                .filter { nature in
                    !self.selectedNatures.contains(where: { $0.nature == nature.name })
                }
            guard !query.isEmpty else {
                let results = natures.map { DynamicResult(key: $0.id, value: $0.name) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = natures.filter { state in
                self.searchMatch(query: queryRegex, with: state.name) != nil
            }.map { DynamicResult(key: $0.id, value: $0.name) }

            completion(results)
        }

        naturesField?.resultByKey = { key, completion in
            let natures = self.dataSource.natures
                .filter { nature in
                    !self.selectedNatures.contains(where: { $0.nature == nature.name })
                }
            let result = natures.first(where: { $0.id == key }).map {
                DynamicResult(key: $0.id, value: $0.name)
            }
            completion(result)
        }
    }

    internal func setupSituationsField() {
        situationsField?.onChangeQuery = { query, completion in
            guard !query.isEmpty else {
                let results = self.dataSource.objectData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = self.dataSource.objectData.filter { state in
                self.searchMatch(query: queryRegex, with: state.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        situationsField?.resultByKey = { key, completion in
            let result = self.dataSource.objectData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
    }
}
