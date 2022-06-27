//
//  RecentsOccurrencesDataSource.swift
//  CAD
//
//  Created by Samir Chaves on 03/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import CoreLocation
import AgenteDeCampoCommon
import MapKit

protocol RecentOccurrencesDataSourceDelegate: class {
    func didUpdateRecentOccurrences(_ occurrences: [SimpleOccurrence])
    func didFetchRecentOccurrences(_ occurrences: [SimpleOccurrence])
    func startLoading()
    func endLoading()
    func didOccurErrorInFetch(_ error: NSError)
}

extension RecentOccurrencesDataSourceDelegate {
    func didFetchRecentOccurrences(_ occurrences: [SimpleOccurrence]) {}
    func startLoading() {}
    func endLoading() {}
    func didOccurErrorInFetch(_ error: NSError) {}
}

class RecentOccurrencesDataSource {
    private var delegates = [RecentOccurrencesDataSourceDelegate?]()

    static let shared = RecentOccurrencesDataSource()

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    @CadServiceInject
    private var cadService: CadService

    private var refreshingTimer: Timer?
    private var allOccurrences = [SimpleOccurrence]()
    private var lastLocation: CLLocationCoordinate2D?
    private var lastRadius: CGFloat?

    private(set) var occurrences = [SimpleOccurrence]()

    typealias RecentOccurrenceFilter = [RecentOccurrenceProperty: [Any]]

    private var filters = RecentOccurrenceFilter()

    var filtersCount: Int {
        filters.filter { !$1.isEmpty}.count
    }

    enum RecentOccurrenceProperty {
        case time, priority, situation, nature, placeType, team, operatingRegion
    }

    func generalAlerts() -> [SimpleOccurrence] {
        allOccurrences.filter { $0.generalAlert }
    }

    func priorities() -> [OccurrencePriority] {
        allOccurrences.map { $0.priority }.uniqued()
    }

    func situations() -> [OccurrenceSituation] {
        allOccurrences.map { $0.situation }.uniqued()
    }

    func operatingRegions() -> [OperatingRegion] {
        allOccurrences.map { $0.operatingRegion }.uniqued()
    }

    func natures() -> [BasicNature] {
        allOccurrences.flatMap { $0.natures }.uniqued()
    }

    func placeTypes() -> [PlaceType] {
        allOccurrences
            .map { occurrence in
                guard let placeType = occurrence.address.placeType else { return nil }
                guard let placeTypeDescription = occurrence.address.placeTypeDescription else { return nil }
                return PlaceType(code: "\(placeType)", description: placeTypeDescription)
            }
            .compactMap { $0 }
            .uniqued()
    }

    func teams() -> [SimpleTeam] {
        allOccurrences.flatMap { $0.allocatedTeams }.uniqued()
    }

    func filter(_ filters: RecentOccurrenceFilter) {
        self.filters = filters
        filter()
    }

    func addDelegate(_ delegate: RecentOccurrencesDataSourceDelegate) {
        delegates.append(delegate)
    }

    enum ResultOccurrenceField: String {
        case address = "Endereço"
        case operatingRegion = "Região de Atuação"
        case priority = "Prioridade"
        case situation = "Situação"
        case `protocol` = "Protocolo"
        case `operator` = "Operador"
        case nature = "Natureza"
        case team = "Equipe"
    }

    struct SearchResult {
        let field: ResultOccurrenceField
        let value: String
        let range: NSRange
        let occurrence: SimpleOccurrence
    }

    typealias SearchField = (field: ResultOccurrenceField, value: String)

    private func searchMatch(query: NSRegularExpression, with term: String) -> NSRange? {
        let foldedTerm = term.prepareForSearch()
        let range = NSRange(location: 0, length: foldedTerm.count)
        return query.firstMatch(in: foldedTerm, options: [], range: range)?.range
    }

    private func occurrenceMatches(occurrence: SimpleOccurrence, with query: NSRegularExpression) -> SearchResult? {
        var possibleFieldsToCheck: [SearchField?] = [
            // Location
            occurrence.address.city.map { (field: .address, value: $0) },
            occurrence.address.district.map { (field: .address, value: $0) },
            occurrence.address.highway.map { (field: .address, value: $0) },
            occurrence.address.number.map { (field: .address, value: $0) },
            occurrence.address.placeTypeDescription.map { (field: .address, value: $0) },
            occurrence.address.referencePoint.map { (field: .address, value: $0) },
            occurrence.address.state.map { (field: .address, value: $0) },
            occurrence.address.street.map { (field: .address, value: $0) },

            // Operating Region
            (field: .operatingRegion, value: occurrence.operatingRegion.agency.initials),
            (field: .operatingRegion, value: occurrence.operatingRegion.agency.name),
            (field: .operatingRegion, value: occurrence.operatingRegion.initials),
            (field: .operatingRegion, value: occurrence.operatingRegion.name),

            // General Info
            (field: .priority, value: occurrence.priority.rawValue),
            (field: .situation, value: occurrence.situation.rawValue),
            (field: .protocol, value: occurrence.protocol),
            (occurrence.operator?.name).map { (field: .operator, value: $0) }
        ]

        // Natures
        possibleFieldsToCheck.append(
            contentsOf: occurrence.natures.map { $0.name }.map { (field: .nature, value: $0) }
        )

        // Teams
        possibleFieldsToCheck.append(
            contentsOf: occurrence.allocatedTeams.map { $0.name }.map { (field: .team, value: $0) }
        )

        let fieldsToCheck = possibleFieldsToCheck.compactMap { $0 }

        return fieldsToCheck.first { searchField in
            return searchMatch(query: query, with: searchField.value) != nil
        }.map { searchField in
            let range = searchMatch(query: query, with: searchField.value)
            let emptyRange = NSRange(location: 0, length: 0)
            return SearchResult(
                field: searchField.field,
                value: searchField.value,
                range: range ?? emptyRange,
                occurrence: occurrence
            )
        }
    }

    func search(by query: String) -> [SearchResult] {
        guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                        options: [.caseInsensitive, .ignoreMetacharacters]) else { return [] }
        return allOccurrences.map { occurrence in
            occurrenceMatches(occurrence: occurrence, with: queryRegex)
        }.compactMap { $0 }
    }

    private func timeFilter(secondsDiff: Int, value: Int) -> Bool {
        if value == 24 {
            return abs(secondsDiff) < 24 * 60 * 60
        } else {
            return abs(secondsDiff) > value * 60 * 60
        }
    }

    private func checkTime(of occurrence: SimpleOccurrence, for values: [Any]) -> Bool {
        if let values = values as? [Int],
           let dateTime = occurrence.serviceRegisteredAt.dateTime.toDate(format: "yyyy-MM-dd'T'HH:mm:ss"),
           let secondsDiff = dateTime.difference(to: Date(), [.second]).second,
           !values.isEmpty,
           values.allSatisfy({ timeFilter(secondsDiff: secondsDiff, value: $0) }) {
            return false
        }
        return true
    }

    private func checkPlaceType(of occurrence: SimpleOccurrence, for values: [Any]) -> Bool {
        if let values = values as? [Int],
           let placeType = occurrence.address.placeType,
           !values.isEmpty,
           !values.contains(placeType) {
            return false
        }
        return true
    }

    private func checkNature(of occurrence: SimpleOccurrence, for values: [Any]) -> Bool {
        if let values = values as? [UUID],
           !values.isEmpty {
            let natures = Set(occurrence.natures.map { $0.id })
            let chosen = Set(values)
            if natures.isDisjoint(with: chosen) {
                return false
            }
        }
        return true
    }

    private func checkOperatingRegions(of occurrence: SimpleOccurrence, for values: [Any]) -> Bool {
        if let values = values as? [UUID],
           !values.isEmpty,
           !values.contains(occurrence.operatingRegion.id) {
            return false
        }
        return true
    }

    private func checkPriority(of occurrence: SimpleOccurrence, for values: [Any]) -> Bool {
        if let values = values as? [OccurrencePriority],
           !values.isEmpty,
           !values.contains(occurrence.priority) {
            return false
        }
        return true
    }

    private func checkTeam(of occurrence: SimpleOccurrence, for values: [Any]) -> Bool {
        if let values = values as? [UUID],
           !values.isEmpty {
            let teams = Set(occurrence.allocatedTeams.map { $0.id })
            let chosen = Set(values)
            if teams.isDisjoint(with: chosen) {
                return false
            }
        }
        return true
    }

    private func checkSituation(of occurrence: SimpleOccurrence, for values: [Any]) -> Bool {
        if let values = values as? [OccurrenceSituation],
           !values.isEmpty,
           !values.contains(occurrence.situation) {
            return false
        }
        return true
    }

    private func occurrenceSatisfies(_ occurrence: SimpleOccurrence, property: RecentOccurrenceProperty, for values: [Any]) -> Bool {
        switch property {
        case .time:
            return checkTime(of: occurrence, for: values)
        case .placeType:
            return checkPlaceType(of: occurrence, for: values)
        case .nature:
            return checkNature(of: occurrence, for: values)
        case .operatingRegion:
            return checkOperatingRegions(of: occurrence, for: values)
        case .priority:
            return checkPriority(of: occurrence, for: values)
        case .team:
            return checkTeam(of: occurrence, for: values)
        case .situation:
            return checkSituation(of: occurrence, for: values)
        }
    }

    private func filter() {
        occurrences = allOccurrences.filter { occurrence in
            if filters.isEmpty {
                return true
            }

            for (property, values) in filters {
                let satisfies = self.occurrenceSatisfies(occurrence, property: property, for: values)
                if !satisfies {
                    return false
                }
            }
            return true
        }

        self.delegates.forEach { $0?.didUpdateRecentOccurrences(occurrences) }
    }

    func refetch(completion: ((Error?) -> Void)? = nil) {
        if let lastRadius = lastRadius,
           let lastLocation = lastLocation {
            internalFetchRecentOccurrences(location: lastLocation, radius: lastRadius, completion: completion)
        } else {
            completion?(nil)
        }
    }

    private func internalFetchRecentOccurrences(location: CLLocationCoordinate2D, radius: CGFloat, completion: ((Error?) -> Void)? = nil) {
        self.delegates.forEach { $0?.startLoading() }
        let coordinates = LocationCoordinates(latitude: location.latitude, longitude: location.longitude)
        occurrenceService.recent(coordinates, radius: Int(radius)) { result in
            switch result {
            case .success(let occurrences):
                garanteeMainThread {
                    self.delegates.forEach { $0?.endLoading() }
                    self.allOccurrences = occurrences
                    self.delegates.forEach { $0?.didFetchRecentOccurrences(occurrences) }
                    self.filter()
                    self.lastLocation = location
                    self.lastRadius = radius
                }
                completion?(nil)
            case .failure(let error):
                garanteeMainThread {
                    self.delegates.forEach { $0?.didOccurErrorInFetch(error as NSError) }
                }
                completion?(error)
            }
        }
    }

    func fetchRecentOccurrences(location: CLLocationCoordinate2D, radius: CGFloat, completion: ((Error?) -> Void)? = nil) {
        if let refreshingTimer = refreshingTimer, refreshingTimer.isValid {
            startRefreshing()
        }

        internalFetchRecentOccurrences(location: location, radius: radius) { error in
            completion?(error)
        }
    }

    func startRefreshing() {
        refreshingTimer?.invalidate()
        self.refreshingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.refetch()
        }
    }

    func stopRefreshing() {
        refreshingTimer?.invalidate()
    }
}
