//
//  DomainService.swift
//  CAD
//
//  Created by Samir Chaves on 11/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import RestClient
import Logger

public protocol DomainService {
    func getOccurrenceValues(completion: @escaping(Result<OccurrencesDomain, Error>) -> Void)
    func loadNaturesGroups()
    func loadNaturesGroups(completion: ((Error?) -> Void)?)
    func getGroupByNature(_ nature: String) -> String?
    func getRoadsData(completion: @escaping (Result<RoadsDomain, Error>) -> Void)
    func getVehiclesData(completion: @escaping (Result<VehiclesDomain, Error>) -> Void)
    func getDrugsData(completion: @escaping (Result<DrugsDomain, Error>) -> Void)
    func getWeaponsData(completion: @escaping (Result<WeaponsDomain, Error>) -> Void)
    func getInvolvedsData(completion: @escaping (Result<InvolvedsDomain, Error>) -> Void)
}

class DomainServiceImpl: Service, DomainService {
    @CadServiceInject
    private var cadService: CadService

    private static var naturesCache = [String: String]()

    public func getOccurrenceValues(completion: @escaping (Result<OccurrencesDomain, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível consultar os dados de ocorrências.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient.path("/cad/domains/occurrences").build()

        rest?.get(completion: completion)
    }

    public func loadNaturesGroups() {
        self.loadNaturesGroups(completion: nil)
    }

    public func loadNaturesGroups(completion: ((Error?) -> Void)?) {
        guard let cadClient = cadService.getCadClient() else {
            completion?(NSError(domain: "Não foi possível consultar os dados de naturezas do CAD.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient.path("/cad/domains/natures").build()

        rest?.get(completion: { (result: Result<[String: [DomainValue]], Error>) in
            switch result {
            case .success(let natureGroups):
                natureGroups.forEach { item in
                    let (group, naturesValues) = item
                    naturesValues.forEach { value in
                        let nature = value.option
                        DomainServiceImpl.naturesCache[nature] = group
                    }
                }
                completion?(nil)
            case .failure(let error):
                completion?(error)
            }
        })
    }

    func getGroupByNature(_ nature: String) -> String? {
        DomainServiceImpl.naturesCache[nature]
    }

    func getRoadsData(completion: @escaping (Result<RoadsDomain, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            let error = NSError(domain: "Não foi possível consultar alguns dados do CAD.", code: 400, userInfo: nil)
            completion(.failure(error))
            return
        }

        let rest = cadClient.path("/cad/domains/roads").build()
        rest?.get(completion: completion)
    }

    public func getVehiclesData(completion: @escaping (Result<VehiclesDomain, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            let error = NSError(domain: "Não foi possível consultar alguns dados do CAD.", code: 400, userInfo: nil)
            completion(.failure(error))
            return
        }

        let rest = cadClient.path("/cad/domains/vehicles").build()
        rest?.get(completion: completion)
    }

    public func getWeaponsData(completion: @escaping (Result<WeaponsDomain, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            let error = NSError(domain: "Não foi possível consultar alguns dados do CAD.", code: 400, userInfo: nil)
            completion(.failure(error))
            return
        }

        let rest = cadClient.path("/cad/domains/weapons").build()
        rest?.get(completion: completion)
    }

    public func getDrugsData(completion: @escaping (Result<DrugsDomain, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            let error = NSError(domain: "Não foi possível consultar alguns dados do CAD.", code: 400, userInfo: nil)
            completion(.failure(error))
            return
        }

        let rest = cadClient.path("/cad/domains/drugs").build()
        rest?.get(completion: completion)
    }

    public func getInvolvedsData(completion: @escaping (Result<InvolvedsDomain, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            let error = NSError(domain: "Não foi possível consultar alguns dados do CAD.", code: 400, userInfo: nil)
            completion(.failure(error))
            return
        }

        let rest = cadClient.path("/cad/domains/involved").build()
        rest?.get(completion: completion)
    }
}

@propertyWrapper
public struct domainServiceInject {
    private var value: DomainService

    public init() {
        self.value = DomainServiceImpl()
    }

    public var wrappedValue: DomainService { value }
}
