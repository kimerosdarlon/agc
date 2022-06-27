//
//  OccurrenceService.swift
//  CAD
//
//  Created by Samir Chaves on 08/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import RestClient
import Logger

public protocol OccurrenceService {
    func getOccurrenceById(_ id: UUID, completion: @escaping(Result<OccurrenceDetails, Error>) -> Void)
    func search(_ filters: [String: Any], completion: @escaping(Result<[SimpleOccurrence], Error>) -> Void)
    func recent(_ location: LocationCoordinates?, radius: Int?, completion: @escaping(Result<[SimpleOccurrence], Error>) -> Void)
    func placeTypes( completion: @escaping(Result<[PlaceType], Error>) -> Void)
    func populateDispatchReleaseReasons()
    func getDispatchReleaseReasons() -> [DispatchReleaseReason]

    func update(occurrenceId: UUID, address: AddressUpdate, completion: @escaping (Error?) -> Void)
    func update(occurrenceId: UUID, report: ReportUpdate, completion: @escaping (Error?) -> Void)
    func update(occurrenceId: UUID, vehicle: VehicleUpdate, completion: @escaping (Error?) -> Void)
    func update(occurrenceId: UUID, weapon: WeaponUpdate, completion: @escaping (Error?) -> Void)
    func update(occurrenceId: UUID, drug: DrugUpdate, completion: @escaping (Error?) -> Void)
    func update(occurrenceId: UUID, involved: InvolvedUpdate, completion: @escaping (Error?) -> Void)

    func delete(occurrenceId: UUID, vehicle: VehicleDelete, completion: @escaping (Error?) -> Void)
    func delete(occurrenceId: UUID, weapon: WeaponDelete, completion: @escaping (Error?) -> Void)
    func delete(occurrenceId: UUID, drug: DrugDelete, completion: @escaping (Error?) -> Void)
    func delete(occurrenceId: UUID, involved: InvolvedDelete, completion: @escaping (Error?) -> Void)

    func addNature(occurrenceId: UUID, nature: NatureUpdate, completion: @escaping (Error?) -> Void)
    func addVehicle(occurrenceId: UUID, vehicle: VehicleInsert, completion: @escaping (Result<[IdVersion], Error>) -> Void)
    func addWeapon(occurrenceId: UUID, weapon: WeaponInsert, completion: @escaping (Result<[IdVersion], Error>) -> Void)
    func addInvolved(occurrenceId: UUID, involved: InvolvedInsert, completion: @escaping (Result<[IdVersion], Error>) -> Void)
    func addDrug(occurrenceId: UUID, drug: DrugInsert, completion: @escaping (Result<[IdVersion], Error>) -> Void)

    func removeNature(occurrenceId: UUID, natureId: UUID, teamId: UUID, completion: @escaping (Error?) -> Void)

    func pdf(occurrenceId: UUID, policeChiefName: String?, policeOffice: String?, fileName: String, completion: @escaping (Result<URL, Error>) -> Void)
}

private class OccurrenceServiceCache {
    fileprivate static var dispatchReleaseReasons = [DispatchReleaseReason]()
}

class OccurrenceServiceImpl: Service, OccurrenceService {
    @CadServiceInject
    private var cadService: CadService

    public func getOccurrenceById(_ id: UUID, completion: @escaping (Result<OccurrenceDetails, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível consultar a ocorrência.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .path("/cad/occurrences/v1/\(id.uuidString)")
            .build()

        rest?.get(completion: completion)
    }

    public func search(_ filters: [String: Any], completion: @escaping (Result<[SimpleOccurrence], Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível buscar as ocorrências.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .path("/cad/occurrences/search")
            .params(filters)
            .build()

        rest?.get(completion: completion)
    }

    public func placeTypes(completion: @escaping (Result<[PlaceType], Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível consultar os tipos de locais.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .path("/cad/occurrences/place-types")
            .build()

        rest?.get(completion: completion)
    }

    public func recent(_ location: LocationCoordinates?, radius: Int?, completion: @escaping(Result<[SimpleOccurrence], Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível consultar as ocorrências recentes.", code: 400, userInfo: nil)))
            return
        }

        var params = [String: Any]()

        if let location = location, let radius = radius {
            params = [
                "latitude": location.latitude,
                "longitude": location.longitude,
                "radius": radius
            ]
        }

        let rest = cadClient
            .acceptJson()
            .path("/cad/occurrences/search/recent")
            .params(params)
            .build()

        rest?.get(completion: completion)
    }

    func populateDispatchReleaseReasons() {
        guard let cadClient = cadService.getCadClient() else { return }

        let rest = cadClient
            .acceptJson()
            .path("/cad/occurrences/closure-reasons")
            .build()

        rest?.get { (result: Result<[DispatchReleaseReason], Error>) in
            switch result {
            case .success(let reasons):
                OccurrenceServiceCache.dispatchReleaseReasons = reasons
            case .failure:
                OccurrenceServiceCache.dispatchReleaseReasons = []
            }
        }
    }

    func getDispatchReleaseReasons() -> [DispatchReleaseReason] {
        OccurrenceServiceCache.dispatchReleaseReasons
    }

    func update(occurrenceId: UUID, address: AddressUpdate, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível atualizar a ocorrência.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/address")
            .body(address)
            .build()

        rest?.put { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func update(occurrenceId: UUID, report: ReportUpdate, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível atualizar a ocorrência.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/report")
            .body(report)
            .build()

        rest?.put { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func update(occurrenceId: UUID, vehicle: VehicleUpdate, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível atualizar a ocorrência.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/vehicles")
            .body(vehicle)
            .build()

        rest?.put { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func update(occurrenceId: UUID, weapon: WeaponUpdate, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível atualizar a ocorrência.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/weapons")
            .body(weapon)
            .build()

        rest?.put { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func update(occurrenceId: UUID, drug: DrugUpdate, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível atualizar a ocorrência.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/drugs")
            .body(drug)
            .build()

        rest?.put { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func update(occurrenceId: UUID, involved: InvolvedUpdate, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível atualizar a ocorrência.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/involved")
            .body(involved)
            .build()

        rest?.put { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func delete(occurrenceId: UUID, involved: InvolvedDelete, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível remover o objeto.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/involved")
            .body(involved)
            .build()

        rest?.delete { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func delete(occurrenceId: UUID, vehicle: VehicleDelete, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível remover o objeto.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/vehicles")
            .body(vehicle)
            .build()

        rest?.delete { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func delete(occurrenceId: UUID, weapon: WeaponDelete, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível remover o objeto.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/weapons")
            .body(weapon)
            .build()

        rest?.delete { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func delete(occurrenceId: UUID, drug: DrugDelete, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível remover o objeto.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/drugs")
            .body(drug)
            .build()

        rest?.delete { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func addNature(occurrenceId: UUID, nature: NatureUpdate, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível atualizar a ocorrência.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/natures")
            .body(nature)
            .build()

        rest?.post { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func addVehicle(occurrenceId: UUID, vehicle: VehicleInsert, completion: @escaping (Result<[IdVersion], Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível adicionar o veículo.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/vehicles")
            .body(vehicle)
            .build()

        rest?.post(completion: completion)
    }

    func addWeapon(occurrenceId: UUID, weapon: WeaponInsert, completion: @escaping (Result<[IdVersion], Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível adicionar a arma.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/weapons")
            .body(weapon)
            .build()

        rest?.post(completion: completion)
    }

    func addInvolved(occurrenceId: UUID, involved: InvolvedInsert, completion: @escaping (Result<[IdVersion], Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível adicionar o envolvido.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/involved")
            .body(involved)
            .build()

        rest?.post(completion: completion)
    }

    func addDrug(occurrenceId: UUID, drug: DrugInsert, completion: @escaping (Result<[IdVersion], Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível adicionar a droga.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/drugs")
            .body(drug)
            .build()

        rest?.post(completion: completion)
    }

    func removeNature(occurrenceId: UUID, natureId: UUID, teamId: UUID, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível remover a natureza.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .ContentTypeJson()
            .path("/cad/occurrences/\(occurrenceId.uuidString)/natures")
            .body(NatureDelete(natureId: natureId, teamId: teamId))
            .build()

        rest?.delete { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func pdf(occurrenceId: UUID, policeChiefName: String?, policeOffice: String?, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi gerar o relatório da ocorrência.", code: 400, userInfo: nil)))
            return
        }

        var params = [String: Any]()

        if let policeChiefName = policeChiefName,
           let policeOffice = policeOffice {
            params = [
                "policeChiefName": policeChiefName,
                "policeOffice": policeOffice
            ]
        }

        let rest = cadClient
            .path("/cad/occurrences/\(occurrenceId.uuidString)/pdf")
            .params(params)
            .build()

        rest?.get { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                let path = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
                do {
                    try data.write(to: path)
                } catch let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(path))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

@propertyWrapper
public struct OccurrenceServiceInject {
    private var value: OccurrenceService

    public init() {
        self.value = OccurrenceServiceImpl()
    }

    public var wrappedValue: OccurrenceService { value }
}
