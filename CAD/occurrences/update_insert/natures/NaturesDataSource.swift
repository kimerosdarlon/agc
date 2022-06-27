//
//  NaturesDataSource.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

class NaturesDataSource<T: OccurrenceObjectUpdate> {

    @CadServiceInject
    private var cadService: CadService

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    @domainServiceInject
    private var domainService: DomainService

    private(set) var natures = [Nature]()
    var selectedNature: UUID?
    private(set) var objectData = [DomainValue]()
    var selectedObjectData: String?
    private let agencyId: String
    private let objectType: OccurrenceObjectType
    private let objectUpdate: T
    private var needCreateExternalId: Bool

    init(agencyId: String, object: T, objectType: OccurrenceObjectType, needCreateExternalId: Bool) {
        self.agencyId = agencyId
        self.objectUpdate = object
        self.objectType = objectType
        self.needCreateExternalId = needCreateExternalId
    }

    func getNatureBy(id: UUID) -> Nature? {
        natures.first(where: { $0.id == id })
    }

    func getObjectDataBy(id: String) -> DomainValue? {
        objectData.first(where: { $0.option == id })
    }

    private func fetchDrugsData(completion: @escaping (Error?) -> Void) {
        domainService.getDrugsData { result in
            switch result {
            case .success(let data):
                self.objectData = data.situations
            case .failure(let error):
                completion(error)
            }
        }
    }

    private func fetchInvolvedsData(completion: @escaping (Error?) -> Void) {
        domainService.getInvolvedsData { result in
            switch result {
            case .success(let data):
                self.objectData = data.involvements
            case .failure(let error):
                completion(error)
            }
        }
    }

    private func fetchVehiclesData(completion: @escaping (Error?) -> Void) {
        domainService.getVehiclesData { result in
            switch result {
            case .success(let data):
                self.objectData = data.involvements
            case .failure(let error):
                completion(error)
            }
        }
    }

    private func fetchWeaponsData(completion: @escaping (Error?) -> Void) {
        domainService.getWeaponsData { result in
            switch result {
            case .success(let data):
                self.objectData = data.situations
            case .failure(let error):
                completion(error)
            }
        }
    }

    func fetchObjectData(completion: @escaping (Error?) -> Void) {
        switch objectType {
        case .drug:
            fetchDrugsData(completion: completion)
        case .involved:
            fetchInvolvedsData(completion: completion)
        case .vehicle:
            fetchVehiclesData(completion: completion)
        case .weapon:
            fetchWeaponsData(completion: completion)
        }
    }

    func fetchNatures(completion: @escaping (Error?) -> Void) {
        cadService.getNatures(agencyId: agencyId) { result in
            switch result {
            case .success(let natures):
                self.natures = natures
            case .failure(let error):
                completion(error)
            }
        }
    }

    private func addNatureToObjectWithExternalId(occurrenceId: UUID, nature: OccurrenceObjectNature, completion: @escaping (Result<[IdVersion], Error>) -> Void) {
        let natureId = nature.natureId
        let natureError = NSError(domain: "Natureza não encontrada.", code: 0, userInfo: nil)
        guard let natureName = getNatureBy(id: natureId)?.name else { completion(.failure(natureError)); return }

        let situationError = NSError(domain: "Situação não encontrada.", code: 0, userInfo: nil)
        needCreateExternalId = false

        switch objectType {
        case .drug:
            guard let drugUpdate = objectUpdate as? DrugUpdate,
                  let situation  = nature.situationId else { completion(.failure(situationError)); return }

            let drugInsert = drugUpdate.toInsert(objectSituations: [
                ObjectSituation(situation: situation, nature: natureId, natureName: natureName)
            ])
            self.occurrenceService.addDrug(occurrenceId: occurrenceId,
                                           drug: drugInsert,
                                           completion: completion)
        case .involved:
            guard let involvedUpdate = objectUpdate as? InvolvedUpdate,
                  let involvement  = nature.situationId else { completion(.failure(situationError)); return }

            let involvedInsert = involvedUpdate.toInsert(naturesAndInvolvements: [
                NatureInvolvement(involvement: involvement, nature: natureId)
            ])
            self.occurrenceService.addInvolved(occurrenceId: occurrenceId,
                                               involved: involvedInsert,
                                               completion: completion)
        case .weapon:
            guard let weaponUpdate = objectUpdate as? WeaponUpdate,
                  let situation  = nature.situationId else { completion(.failure(situationError)); return }

            let weaponInsert = weaponUpdate.toInsert(objectSituations: [
                ObjectSituation(situation: situation, nature: natureId, natureName: natureName)
            ])
            occurrenceService.addWeapon(occurrenceId: occurrenceId,
                                        weapon: weaponInsert,
                                        completion: completion)

        case .vehicle:
            guard let vehicleUpdate = objectUpdate as? VehicleUpdate,
                  let involvement  = nature.situationId else { completion(.failure(situationError)); return }

            let vehicleInsert = vehicleUpdate.toInsert(naturesAndInvolvements: [
                NatureInvolvement(involvement: involvement, nature: natureId)
            ])
            occurrenceService.addVehicle(occurrenceId: occurrenceId,
                                         vehicle: vehicleInsert,
                                         completion: completion)
        }
    }

    func addNatureToObject(occurrenceId: UUID, nature: OccurrenceObjectNature, completion: @escaping (Result<[IdVersion], Error>) -> Void) {
        let situationError = NSError(domain: "Situação não encontrada.", code: 0, userInfo: nil)
        if needCreateExternalId {
            switch objectType {
            case .drug:
                guard let drugUpdate = objectUpdate as? DrugUpdate else {
                    completion(.failure(situationError))
                    return
                }
                occurrenceService.update(occurrenceId: occurrenceId, drug: drugUpdate) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.addNatureToObjectWithExternalId(occurrenceId: occurrenceId, nature: nature, completion: completion)
                    }
                }
            case .involved:
                guard let involvedUpdate = objectUpdate as? InvolvedUpdate else {
                    completion(.failure(situationError))
                    return
                }
                occurrenceService.update(occurrenceId: occurrenceId, involved: involvedUpdate) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.addNatureToObjectWithExternalId(occurrenceId: occurrenceId, nature: nature, completion: completion)
                    }
                }
            case .weapon:
                guard let weaponUpdate = objectUpdate as? WeaponUpdate else {
                    completion(.failure(situationError))
                    return
                }
                occurrenceService.update(occurrenceId: occurrenceId, weapon: weaponUpdate) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.addNatureToObjectWithExternalId(occurrenceId: occurrenceId, nature: nature, completion: completion)
                    }
                }
            case .vehicle:
                guard let vehicleUpdate = objectUpdate as? VehicleUpdate else {
                    completion(.failure(situationError))
                    return
                }
                occurrenceService.update(occurrenceId: occurrenceId, vehicle: vehicleUpdate) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.addNatureToObjectWithExternalId(occurrenceId: occurrenceId, nature: nature, completion: completion)
                    }
                }
            }
        } else {
            self.addNatureToObjectWithExternalId(occurrenceId: occurrenceId, nature: nature, completion: completion)
        }
    }
}
