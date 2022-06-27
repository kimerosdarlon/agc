//
//  PlacesService.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 01/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import RestClient

public protocol PlacesService {
    func loadData(completion: (() -> Void)?)
    func getStates() -> [State]
    func getStateBy(initials: String) -> State?
    func getCitiesFor(state: String) -> [City]
    func getCityBy(code: Int) -> City?
}

public class PlacesServiceImpl: PlacesService {
    var enviroment = ACEnviroment.shared
    var token: String {
        TokenService().getApplicationToken() ?? ""
    }

    private let cacheExpiration: TimeInterval = 60 * 60 * 24 * 7 // 7 days

    private static var statesCache = [State]()
    private static var citiesByStateCache = [String: [City]]()
    private static var cityByCodeCache = [Int: City]()

    private func storedCheckpoint() {
        UserDefaults.standard.set(Date().format(to: "yyyy-MM-dd'T'HH:mm:ss"), forKey: "places_storage_checkpoint")
    }

    private func getlastCheckpoint() -> Date? {
        UserDefaults.standard.string(forKey: "places_storage_checkpoint")?.toDate(format: "yyyy-MM-dd'T'HH:mm:ss")
    }

    private func needFetchData() -> Bool {
        guard let lastCheckpoint = getlastCheckpoint() else { return true }
        if let difference = lastCheckpoint.difference(to: Date(), [.second]).second,
           TimeInterval(difference) > cacheExpiration {
            return true
        }
        return false
    }

    private func store(data: [StateWithCities]) {
        let placesData = try? JSONEncoder().encode(data)
        UserDefaults.standard.set(placesData, forKey: "states_with_cities")
    }

    private func restoreData() -> [StateWithCities]? {
        if let placesData = UserDefaults.standard.data(forKey: "states_with_cities") {
            let places = try? JSONDecoder().decode([StateWithCities].self, from: placesData)
            return places
        }
        return nil
    }

    private var client: RestTemplateBuilder {
        return RestTemplateBuilder(enviroment: self.enviroment)
            .addToken(token: token)
            .acceptJson()
    }

    private func fetchData(completion: (() -> Void)? = nil) {
        let rest = client.path("/states-with-cities").build()
        rest?.get(completion: { (result: Result<[StateWithCities], Error>) in
            completion?()
            switch result {
            case .success(let statesWithCities):
                self.populate(data: statesWithCities)
                self.storedCheckpoint()
                self.store(data: statesWithCities)
            case .failure:
                PlacesServiceImpl.statesCache = []
            }
        })
    }

    private func populate(data statesWithCities: [StateWithCities]) {
        PlacesServiceImpl.statesCache = statesWithCities.map { $0.withoutCity() }
        let cities = statesWithCities.flatMap { $0.cities }
        let citiesByCode = cities.map { ($0.ibgeCode, $0) }
        let citiesByState = statesWithCities.map { ($0.initials, $0.cities) }
        PlacesServiceImpl.cityByCodeCache = Dictionary(uniqueKeysWithValues: citiesByCode)
        PlacesServiceImpl.citiesByStateCache = Dictionary(uniqueKeysWithValues: citiesByState)
    }

    public func loadData(completion: (() -> Void)? = nil) {
        if needFetchData() {
            fetchData(completion: completion)
        } else {
            if let statesWithCities = restoreData() {
                populate(data: statesWithCities)
                completion?()
            } else {
                fetchData(completion: completion)
            }
        }
    }

    public func getStates() -> [State] {
        return PlacesServiceImpl.statesCache
    }

    public func getStateBy(initials: String) -> State? {
        let states = getStates()
        return states.first(where: { $0.initials == initials })
    }

    public func getCitiesFor(state: String) -> [City] {
        return PlacesServiceImpl.citiesByStateCache[state] ?? []
    }

    public func getCityBy(code: Int) -> City? {
        return PlacesServiceImpl.cityByCodeCache[code]
    }
}

@propertyWrapper
public struct PlacesServiceInject {
    private var value: PlacesService

    public init() {
        self.value = PlacesServiceImpl()
    }

    public var wrappedValue: PlacesService { value }
}
