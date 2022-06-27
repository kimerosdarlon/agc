//
//  AddressUpdateViewController+fields.swift
//  CAD
//
//  Created by Samir Chaves on 18/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

extension AddressUpdateViewController {
    internal func searchMatch(query: NSRegularExpression, with term: String) -> NSRange? {
        let foldedTerm = term.prepareForSearch()
        let range = NSRange(location: 0, length: foldedTerm.utf16.count)
        return query.firstMatch(in: foldedTerm, options: [], range: range)?.range
    }

    internal func setupStateField() {
        stateField = SelectComponent(parentViewController: self, label: "Estado", inputPlaceholder: "", canClean: false, showLabel: false)
        stateField?.onChangeQuery = { query, completion in
            guard !query.isEmpty else {
                let results = self.dataSource.states.map { DynamicResult(key: $0.initials, value: $0.name) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = self.dataSource.states.filter { state in
                self.searchMatch(query: queryRegex, with: state.name) != nil
            }.map { DynamicResult(key: $0.initials, value: $0.name) }

            completion(results)
        }

        stateField?.resultByKey = { key, completion in
            let result = self.dataSource.states.first(where: { $0.initials == key }).map {
                DynamicResult(key: $0.initials, value: $0.name)
            }
            completion(result)
        }

        stateField?.setup()

        dataSource.loadPlaceTypes {
            guard let currentState = self.model.address.state else { return }
            garanteeMainThread {
                self.formBuilder?.send(value: currentState, toField: \.state)
            }
        }
    }

    internal func setupCityField() {
        cityField = SelectComponent(parentViewController: self, label: "Cidade", inputPlaceholder: "", canClean: false, showLabel: false)
        cityField?.onChangeQuery = { query, completion in
            guard !query.isEmpty else {
                let results = self.dataSource.cities.map { DynamicResult(key: $0.name.uppercased(), value: $0.name) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = self.dataSource.cities.filter { city in
                self.searchMatch(query: queryRegex, with: city.name) != nil
            }.map { DynamicResult(key: $0.name.uppercased(), value: $0.name) }

            completion(results)
        }

        cityField?.resultByKey = { key, completion in
            let result = self.dataSource.cities.first(where: { $0.name.uppercased() == key }).map {
                DynamicResult(key: $0.name.uppercased(), value: $0.name)
            }
            completion(result)
        }

        cityField?.setup()
    }

    internal func setupPlaceTypeField() {
        placeTypeField = SelectComponent(parentViewController: self, label: "Tipo de Local", inputPlaceholder: "", canClean: false, showLabel: false)
        placeTypeField?.onChangeQuery = { query, completion in
            guard !query.isEmpty else {
                let results = self.dataSource.placeTypes.map { placeType in
                    DynamicResult(key: Int(placeType.code) ?? -1, value: placeType.description)
                }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = self.dataSource.placeTypes.filter { placeType in
                self.searchMatch(query: queryRegex, with: placeType.description) != nil
            }.map { placeType in
                DynamicResult(key: Int(placeType.code) ?? -1, value: placeType.description)
            }
            completion(results)
        }

        placeTypeField?.resultByKey = { key, completion in
            let result = self.dataSource.placeTypes.first(where: { Int($0.code) == key }).map {
                DynamicResult(key: Int($0.code) ?? -1, value: $0.description)
            }
            completion(result)
        }

        placeTypeField?.setup()
    }

    internal func setupRoadTypeField() {
        roadTypeField = SelectComponent(parentViewController: self, label: "Tipo de Via", inputPlaceholder: "", canClean: false, showLabel: false)
        roadTypeField?.onChangeQuery = { query, completion in
            guard !query.isEmpty else {
                let results = self.dataSource.roadTypes.map { roadType in
                    DynamicResult(key: roadType.option, value: roadType.label)
                }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = self.dataSource.roadTypes.filter { roadType in
                self.searchMatch(query: queryRegex, with: roadType.label) != nil
            }.map { roadType in
                DynamicResult(key: roadType.option, value: roadType.label)
            }
            completion(results)
        }

        roadTypeField?.resultByKey = { key, completion in
            let result = self.dataSource.roadTypes.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }

        roadTypeField?.setup()
    }

    internal func setupRoadLaneField() {
        highwayLaneField = SelectComponent(parentViewController: self, label: "Pista da Rodovia", inputPlaceholder: "", canClean: false, showLabel: false)
        highwayLaneField?.onChangeQuery = { query, completion in
            guard !query.isEmpty else {
                let results = self.dataSource.roadLanes.map { roadLane in
                    DynamicResult(key: roadLane.option, value: roadLane.label)
                }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = self.dataSource.roadLanes.filter { roadLane in
                self.searchMatch(query: queryRegex, with: roadLane.label) != nil
            }.map { roadLane in
                DynamicResult(key: roadLane.option, value: roadLane.label)
            }
            completion(results)
        }

        highwayLaneField?.resultByKey = { key, completion in
            let result = self.dataSource.roadLanes.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }

        highwayLaneField?.setup()
    }

    internal func setupRoadDirectionField() {
        roadDirectionField = SelectComponent(parentViewController: self, label: "Sentido da Via", inputPlaceholder: "", canClean: false, showLabel: false)
        roadDirectionField?.onChangeQuery = { query, completion in
            guard !query.isEmpty else {
                let results = self.dataSource.roadways.map { roadway in
                    DynamicResult(key: roadway.option, value: roadway.label)
                }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = self.dataSource.roadways.filter { roadway in
                self.searchMatch(query: queryRegex, with: roadway.label) != nil
            }.map { roadway in
                DynamicResult(key: roadway.option, value: roadway.label)
            }
            completion(results)
        }

        roadDirectionField?.resultByKey = { key, completion in
            let result = self.dataSource.roadways.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }

        roadDirectionField?.setup()
    }
}
