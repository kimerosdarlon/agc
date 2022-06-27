//
//  Test.swift
//  CAD
//
//  Created by Samir Chaves on 18/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import Logger

class AddressUpdateDataSource {

    private lazy var logger = Logger.forClass(Self.self)

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    @PlacesServiceInject
    private var placesService: PlacesService

    @domainServiceInject
    private var domainService: DomainService

    static let shared = AddressUpdateDataSource()

    init() {}

    private(set) var placeTypes = [PlaceType]()
    var selectedState: State?
    private(set) var states = [State]()
    private(set) var cities = [City]()
    private(set) var roadLanes = [DomainValue]()
    private(set) var roadways = [DomainValue]()
    private(set) var roadTypes = [DomainValue]()

    func loadPlaceTypes(completion: @escaping () -> Void) {
        occurrenceService.placeTypes { result in
            switch result {
            case .success(let placeTypes):
                self.placeTypes = placeTypes
            case .failure(let error):
                self.logger.error(error.localizedDescription)
                self.placeTypes = []
            }
            completion()
        }
    }

    func loadStates() {
        states = placesService.getStates()
    }

    func loadCities() {
        guard let selectedState = self.selectedState else { return }
        cities = placesService.getCitiesFor(state: selectedState.initials)
    }

    func getCityByName(_ name: String) -> City? {
        self.cities.first(where: { $0.name.uppercased() == name.uppercased() })
    }

    func getStateByInitials(_ initials: String) -> State? {
        self.states.first(where: { $0.initials.lowercased() == initials.lowercased() })
    }

    func getRoadwayByKey(_ key: String) -> DomainValue? {
        self.roadways.first(where: { $0.option == key })
    }

    func getRoadLaneByKey(_ key: String) -> DomainValue? {
        self.roadLanes.first(where: { $0.option == key })
    }

    func getRoadTypeByKey(_ key: String) -> DomainValue? {
        self.roadTypes.first(where: { $0.option == key })
    }

    func getPlaceTypeByCode(_ code: Int) -> PlaceType? {
        self.placeTypes.first(where: { $0.code == "\(code)" })
    }

    func loadRoadData(completion: @escaping () -> Void) {
        domainService.getRoadsData { result in
            completion()
            switch result {
            case .success(let roadsDomain):
                self.roadways = roadsDomain.roadways
                self.roadLanes = roadsDomain.lanes
                self.roadTypes = roadsDomain.types
            case .failure(let error as NSError):
                self.logger.error(error.localizedDescription)
            }
        }
    }
}
