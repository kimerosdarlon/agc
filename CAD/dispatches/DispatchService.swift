//
//  DispatchService.swift
//  CAD
//
//  Created by Samir Chaves on 17/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import RestClient

struct DispatchConfirm: Codable {
    let dateTime: String
}

struct DispatchStatusesResponse: Codable {
    let intermediatePlaces: [IntermediatePlace]
    let statuses: [RawDispatchStatus]
}

public protocol DispatchService {
    func populateStatuses(completion: @escaping () -> Void)
    func getIntermediatePlaces() -> [IntermediatePlace]
    func updateStatus(of team: UUID,
                      in occurrence: UUID,
                      to newStatus: DispatchStatusCode,
                      intermediatePlace: String?,
                      description: String?,
                      completion: @escaping (Error?) -> Void)
    func updateStatus(of team: UUID,
                      in occurrence: UUID,
                      to newStatus: DispatchStatusCode,
                      completion: @escaping (Error?) -> Void)
    func release(of team: UUID,
                 in occurrence: UUID,
                 command: DispatchReleaseCmd,
                 completion: @escaping (Error?) -> Void)
    func confirmDispatch(of team: UUID, in occurrence: UUID, completion: @escaping (Error?) -> Void)
    func confirmDispatch(completion: @escaping (Error?) -> Void)
    func isDispatchConfirmed(of team: UUID, in occurrence: UUID) -> Bool
    func cleanStoredDispatchConfirm()
}

class DispatchServiceImpl: Service, DispatchService {
    @CadServiceInject
    private var cadService: CadService

    static var intermediatePlaces = [IntermediatePlace]()

    func populateStatuses(completion: @escaping () -> Void) {
        guard let cadClient = cadService.getCadClient() else { return }

        let rest = cadClient
            .acceptJson()
            .path("/cad/dispatches/status")
            .build()

        rest?.get(completion: { (result: Result<DispatchStatusesResponse, Error>) in
            switch result {
            case .success(let response):
                DispatchServiceImpl.intermediatePlaces = response.intermediatePlaces
                response.statuses.forEach { rawStatus in
                    rawStatus.updateDispatchStatus()
                }
                completion()
            case .failure:
                completion()
            }
        })
    }

    func getIntermediatePlaces() -> [IntermediatePlace] {
        return DispatchServiceImpl.intermediatePlaces
    }

    func updateStatus(of team: UUID,
                      in occurrence: UUID,
                      to newStatus: DispatchStatusCode,
                      completion: @escaping (Error?) -> Void) {
        updateStatus(of: team,
                     in: occurrence,
                     to: newStatus,
                     intermediatePlace: nil,
                     description: nil,
                     completion: completion)
    }

    func updateStatus(of team: UUID,
                      in occurrence: UUID,
                      to newStatus: DispatchStatusCode,
                      intermediatePlace: String? = nil,
                      description: String? = nil,
                      completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else { return }

        let rest = cadClient
            .acceptJson().ContentTypeJson()
            .body(
                DispatchUpdateCmd(
                    status: newStatus.rawValue,
                    intermediatePlace: intermediatePlace,
                    description: description
                )
            )
            .path("/cad/dispatches/\(occurrence.uuidString)/\(team.uuidString)/status")
            .build()

        rest?.put(completion: { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }

    func release(of team: UUID,
                 in occurrence: UUID,
                 command: DispatchReleaseCmd,
                 completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else { return }

        let rest = cadClient
            .acceptJson().ContentTypeJson()
            .body(command)
            .path("/cad/dispatches/\(occurrence.uuidString)/\(team.uuidString)/release")
            .build()

        rest?.put(completion: { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }

    func confirmDispatch(of team: UUID, in occurrence: UUID, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else { return }

        let currentDate = (Date().convertToUTC() ?? Date()).format(to: "yyyy-MM-dd'T'HH:mm:ss'Z'")
        let body = DispatchConfirm(dateTime: currentDate)
        let rest = cadClient
            .acceptJson().ContentTypeJson()
            .body(body)
            .path("/cad/dispatches/\(occurrence.uuidString)/\(team.uuidString)/confirm")
            .build()

        rest?.put(completion: { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                self.storeDispatchConfirm(of: team, in: occurrence)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }

    func confirmDispatch(completion: @escaping (Error?) -> Void) {
        let userDefaults = UserDefaults.standard
        guard let cadClient = cadService.getCadClient(),
              let activeTeamIdString = userDefaults.string(forKey: "cad-active-team-id"),
              let activeTeamId = UUID(uuidString: activeTeamIdString),
              let dispatchedOccurrenceIdString = userDefaults.string(forKey: "cad-dispatched-occurrence-id"),
              let dispatchedOccurrenceId = UUID(uuidString: dispatchedOccurrenceIdString) else { return }

        let currentDate = (Date().convertToUTC() ?? Date()).format(to: "yyyy-MM-dd'T'HH:mm:ss'Z'")
        let body = DispatchConfirm(dateTime: currentDate)
        let rest = cadClient
            .acceptJson().ContentTypeJson()
            .body(body)
            .path("/cad/dispatches/\(dispatchedOccurrenceId.uuidString)/\(activeTeamId.uuidString)/confirm")
            .build()

        rest?.put(completion: { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                self.storeDispatchConfirm(of: activeTeamId, in: dispatchedOccurrenceId)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }

    private func storeDispatchConfirm(of team: UUID, in occurrence: UUID) {
        let userDefaults = UserDefaults.standard
        let value = "\(team.uuidString)@\(occurrence.uuidString)"
        userDefaults.setValue(value, forKey: "dispatch_confirm")
    }

    func cleanStoredDispatchConfirm() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "dispatch_confirm")
    }

    func isDispatchConfirmed(of team: UUID, in occurrence: UUID) -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.string(forKey: "dispatch_confirm") else { return false }
        let ids = value.split(separator: "@")
            .map { String($0) }
            .map { UUID(uuidString: $0) }
            .compactMap { $0 }
        guard let storedTeam = ids.first else { return false }
        guard let storedOccurrence = ids.last else { return false }
        return storedTeam == team && storedOccurrence == occurrence
    }
}

@propertyWrapper
public struct DispatchServiceInject {
    private var value: DispatchService

    public init() {
        self.value = DispatchServiceImpl()
    }

    public var wrappedValue: DispatchService { value }
}
