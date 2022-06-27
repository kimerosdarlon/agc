//
//  CADService.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import RestClient
import Logger

class Service {
    var enviroment = ACEnviroment.shared
    var token: String {
        TokenService().getApplicationToken() ?? ""
    }

    open var client: RestTemplateBuilder {
        return RestTemplateBuilder(enviroment: self.enviroment).addToken(token: token)
        .acceptJson()
    }
}

public protocol CadService {
    func realtimeOccurrencesAllowed() -> Bool
    func realtimeExternalTeamsAllowed() -> Bool

    func refreshResource(completion: @escaping (Error?) -> Void)
    func setUserRoles(_ roles: [String])
    func checkIfIsCadResource(completion: @escaping(Result<CadResource?, Error>) -> Void)

    func getActiveTeam() -> Team?
    func getActiveTeams(operatingRegionsIds: [UUID], completion: @escaping(Result<[TeamBasic], Error>) -> Void)
    func getDispatches() -> [TeamDispatch]
    func hasStartedService() -> Bool
    func hasActiveTeam() -> Bool
    func getScheduledTeams() -> [Team]
    func getTeamById(teamId: UUID, completion: @escaping (Result<NonCriticalTeam, Error>) -> Void)
    func finishTeam(teamId: UUID, finishModel: FinishTeam, completion: @escaping (Result<NoContent, Error>) -> Void)
    func setDispatchedOccurrence(_ occurrence: OccurrenceDetails)
    func getDispatchedOccurrence() -> OccurrenceDetails?

    func getProfile() -> PersonProfile?
    func getCadToken() -> String?

    func getAgencies( completion: @escaping(Result<[Agency], Error>) -> Void)
    func getChecklist( completion: @escaping(Result<Checklist, Error>) -> Void)
    func getStoredEquipment() -> Equipment?
    func startService(completion: @escaping (Result<OperationalServiceResponse, Error>) -> Void)
    func startService(withEquipments equipments: [EquipmentKm],
                      andChecklistReply replyForm: ReplyForm,
                      completion: @escaping (Result<OperationalServiceResponse, Error>) -> Void)
    func replyChecklist( reply: ReplyForm, completion: @escaping (Result<NoContent, Error>) -> Void)
    func getNatures(agencyId: String, completion: @escaping(Result<[Nature], Error>) -> Void)
    func getOperatingRegions(agencyId: String, completion: @escaping(Result<[OperatingRegion], Error>) -> Void)

    func getCadClient() -> RestTemplateBuilder?
}

private enum CadRole: String {
    case RTOccurrences = "RL_AGC_CAD_TR_OCORRENCIAS"
    case RTTeamsByOperatingRegion = "RL_AGC_CAD_TR_RA_EQP_ONLINE"
}

private class CadServiceCache {
    fileprivate static var userRoles = [CadRole]()
    fileprivate static var cadResource: CadResource? {
        didSet {
            UserDefaults.standard.set(cadResource?.cadToken, forKey: "cad-token")
        }
    }
    fileprivate static var activeTeam: Team? {
        didSet {
            UserDefaults.standard.set(activeTeam?.id.uuidString, forKey: "cad-active-team-id")
        }
    }
    fileprivate static var teamDispatches = [TeamDispatch]()
    fileprivate static var dispatchedOccurrence: OccurrenceDetails? {
        didSet {
            UserDefaults.standard.set(dispatchedOccurrence?.occurrenceId.uuidString, forKey: "cad-dispatched-occurrence-id")
            UserDefaults.standard.set(dispatchedOccurrence?.address.coordinates?.latitude, forKey: "cad-dispatched-occurrence-lat")
            UserDefaults.standard.set(dispatchedOccurrence?.address.coordinates?.longitude, forKey: "cad-dispatched-occurrence-lng")
        }
    }
}

class CadServiceImpl: Service, CadService {

    lazy var logger = Logger.forClass(Self.self)

    private let cadHeader = "Authorization-Cad"
    private let localDb = UserDefaults.standard

    func setUserRoles(_ roles: [String]) {
        CadServiceCache.userRoles = roles.compactMap { CadRole(rawValue: $0) }
    }

    func realtimeOccurrencesAllowed() -> Bool { CadServiceCache.userRoles.contains(.RTOccurrences) }

    func realtimeExternalTeamsAllowed() -> Bool { CadServiceCache.userRoles.contains(.RTTeamsByOperatingRegion)  }

    func getActiveTeam() -> Team? { CadServiceCache.activeTeam }

    func hasActiveTeam() -> Bool { CadServiceCache.activeTeam != nil }

    func getDispatches() -> [TeamDispatch] { CadServiceCache.teamDispatches }

    func getProfile() -> PersonProfile? { CadServiceCache.cadResource?.resource }

    func getCadToken() -> String? {
        if let cadToken = CadServiceCache.cadResource?.cadToken {
            return cadToken
        }
        if let cadToken = UserDefaults.standard.string(forKey: "cad-token") {
            return cadToken
        }
        return nil
    }

    func refreshResource(completion: @escaping (Error?) -> Void) {
        let center = NotificationCenter.default
        center.post(name: .cadResourceWillChange, object: nil, userInfo: [
            "resource": CadServiceCache.cadResource
        ])
        checkIfIsCadResource { result in
            garanteeMainThread {
                switch result {
                case .success(let resource):
                    center.post(name: .cadResourceDidChange, object: nil, userInfo: [
                        "resource": resource
                    ])
                    if let dispatches = resource?.dispatches, dispatches.isEmpty {
                        center.post(name: .cadTeamDidFinishDispatch, object: nil)
                    }
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }

    func hasStartedService() -> Bool {
        if let activeTeam = getActiveTeam(), let currentTeam = localDb.string(forKey: "service_started_id") {
            return currentTeam.elementsEqual(activeTeam.id.uuidString)
        } else {
            return false
        }
    }

    private func persistServiceStart(activeTeamId: UUID? = nil) {
        if let activeTeamId = activeTeamId {
            localDb.set(activeTeamId.uuidString, forKey: "service_started_id")
            return
        }

        if let activeTeam = getActiveTeam() {
            localDb.set(activeTeam.id.uuidString, forKey: "service_started_id")
        }
    }

    private func internalCheckIfIsCadResource(completion: @escaping (Result<CadResource?, Error>) -> Void, alreadyRetried: Bool? = false) {
        logger.info("Verificando recurso cad")
        if !FeatureFlags.cadModule {
            completion(.success(nil))
            return
        } else if FeatureFlags.mockCadModule {
            DispatchQueue.global(qos: .background).async {
                sleep(1)
                let resource = CadResoureFactory.mockResource()
                if FeatureFlags.mockTeam {
                    CadServiceCache.cadResource = resource
                    CadServiceCache.activeTeam = resource.resource.teams.first
                    CadServiceCache.teamDispatches = []
                }
                completion(.success( resource ))
            }
            return
        }

        let rest = client.path("/cad/resource").build()
        rest?.get(completion: { (result: Result<CadResource, Error> ) in
            switch result {
            case .failure(let error as NSError):
                if error.code == 404 {
                    completion(.success(nil))
                } else if error.code == 500 {
                    if let alreadyRetried = alreadyRetried, alreadyRetried {
                        completion(.failure(error))
                    } else {
                        self.internalCheckIfIsCadResource(completion: completion, alreadyRetried: true)
                    }
                } else {
                    completion(.failure(error))
                }
            case .success(let resource):
                CadServiceCache.cadResource = resource
                CadServiceCache.activeTeam = resource.resource.getActiveTeam()
                CadServiceCache.teamDispatches = resource.dispatches ?? []
                completion(.success(resource))
            }
        })
    }

    func checkIfIsCadResource(completion: @escaping (Result<CadResource?, Error>) -> Void) {
        internalCheckIfIsCadResource(completion: completion, alreadyRetried: false)
    }

    func getScheduledTeams() -> [Team] {
        CadServiceCache.cadResource?.resource.teams ?? []
    }

    func startService(withEquipments equipments: [EquipmentKm], andChecklistReply replyForm: ReplyForm, completion: @escaping (Result<OperationalServiceResponse, Error>) -> Void) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível ativar a equipe.", code: 400, userInfo: nil)))
            return
        }

        let startServiceCmd = StartService(
            activate: ActivateTeam(equipments: equipments),
            checklistReply: ReplyFormSeed(responses: replyForm.responses)
        )
        let rest = cadClient
            .acceptJson().ContentTypeJson()
            .path("/cad/teams/\(replyForm.team.uuidString)/start")
            .body(startServiceCmd)
            .build()

        rest?.put { (result: Result<OperationalServiceResponse, Error>) in
            switch result {
            case .success:
                self.persistServiceStart(activeTeamId: replyForm.team)
                completion(result)
            case .failure:
                completion(result)
            }
        }
    }

    func startService( completion: @escaping (Result<OperationalServiceResponse, Error>) -> Void) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível ativar a equipe.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .path("/cad/teams/me/start")
            .build()

        func operationalServiceCompletion(result: Result<OperationalServiceResponse, Error>) {
            switch result {
            case .success:
                persistServiceStart()
                completion(result)
            case .failure:
                completion(result)
            }
        }

        rest?.put(completion: operationalServiceCompletion)
    }

    func getActiveTeams(operatingRegionsIds: [UUID], completion: @escaping (Result<[TeamBasic], Error>) -> Void) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível recuperar as equipes ativas.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .path("/cad/teams/active")
            .params([
                "operatingRegions": operatingRegionsIds.map { $0.uuidString }
            ])
            .build()

        rest?.get(completion: completion)
    }

    func getChecklist(completion: @escaping (Result<Checklist, Error>) -> Void) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível ativar a equipe.", code: 400, userInfo: nil)))
            return
        }
        let rest = cadClient.path("/cad/checklists").build()

        rest?.get(completion: completion)
    }

    func getStoredEquipment() -> Equipment? {
        let equipmentIdString = UserDefaults.standard.string(forKey: "currentEquipment")
        guard let equipmentId = equipmentIdString.map({ UUID(uuidString: $0) }) else { return nil }
        guard let activeTeam = getActiveTeam() else { return nil }
        return activeTeam.equipments.first(where: { $0.id == equipmentId })
    }

    func getTeamById(teamId: UUID, completion: @escaping (Result<NonCriticalTeam, Error>) -> Void) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível consultar os detalhes da equipe.", code: 400, userInfo: nil)))
            return
        }
        let rest = cadClient.path("/cad/teams/\(teamId.uuidString)").build()

        rest?.get(completion: completion)
    }

    func getAgencies(completion: @escaping (Result<[Agency], Error>) -> Void) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível consultar as agências.", code: 400, userInfo: nil)))
            return
        }
        let rest = cadClient.path("/cad/agencies").build()

        rest?.get { (result: Result<[Agency], Error>) in
            switch result {
            case .success(let agencies):
                if agencies.isEmpty {
                    completion(Result.failure(NSError(domain: "Usuário sem acesso a agências", code: 0, userInfo: nil)))
                } else {
                    completion(result)
                }
            case .failure:
                completion(result)
            }
        }
    }

    func replyChecklist( reply: ReplyForm, completion: @escaping (Result<NoContent, Error>) -> Void ) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível reponder o checklist.", code: 400, userInfo: nil)))
            return
        }
        let rest = cadClient
            .ContentTypeJson()
            .path("/cad/checklists/replies")
            .body( reply )
            .build()

        rest?.post(completion: completion)
    }

    func activateTeam(checklistReply: ReplyForm, completion: @escaping (Result<NoContent, Error>) -> Void ) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível ativar a equipe.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .ContentTypeJson()
            .path("/cad/teams/\(checklistReply.team.uuidString)/activate")
            .body( ActivateTeam(equipments: []) )
            .build()

        replyChecklist(reply: checklistReply) { replyResult in
            switch replyResult {
            case .success:
                rest?.put(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getCadClient() -> RestTemplateBuilder? {
        if let cadToken = getCadToken() {
            return client.addHeader(name: cadHeader, value: cadToken)
        }

        return nil
    }

    func finishTeam(teamId: UUID, finishModel: FinishTeam, completion: @escaping (Result<NoContent, Error>) -> Void ) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível encerrar a equipe.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .ContentTypeJson()
            .path("/cad/teams/\(teamId.uuidString)/stop")
            .body( finishModel )
            .build()

        rest?.put(completion: completion)
    }

    func setDispatchedOccurrence(_ occurrence: OccurrenceDetails) {
        CadServiceCache.dispatchedOccurrence = occurrence
    }

    func getDispatchedOccurrence() -> OccurrenceDetails? {
        CadServiceCache.dispatchedOccurrence
    }

    func getNatures(agencyId: String, completion: @escaping (Result<[Nature], Error>) -> Void) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível buscar as naturezas", code: 400, userInfo: nil)))
            return
        }
        let rest = cadClient
            .path("/cad/agencies/\(agencyId)/natures").build()

        rest?.get(completion: completion)
    }

    func getOperatingRegions(agencyId: String, completion: @escaping(Result<[OperatingRegion], Error>) -> Void) {
        guard let cadClient = getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível buscar as regiões de atuação.", code: 400, userInfo: nil)))
            return
        }
        let rest = cadClient.path("/cad/agencies/\(agencyId)/operating-regions").build()

        rest?.get(completion: completion)
    }
}

@propertyWrapper
public struct CadServiceInject {
    private var value: CadService

    public init() {
        self.value = CadServiceImpl()
    }

    public var wrappedValue: CadService { value }
}
