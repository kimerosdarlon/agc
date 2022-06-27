//
//  RealTimeService.swift
//  CAD
//
//  Created by Samir Chaves on 05/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import IKEventSource
import CoreLocation
import Foundation
import RestClient
import Location
import Logger

extension Notification.Name {
    static let realTimeReceivePosition = Notification.Name.init("realTimeReceivePosition")
}

class StreamService {
    @CadServiceInject
    fileprivate var cadService: CadService

    var enviroment = ACEnviroment.shared
    var token: String {
        TokenService().getApplicationToken() ?? ""
    }

    var client: RestTemplateBuilder {
        return RestTemplateBuilder(enviroment: self.enviroment, basePath: "/streams/api").addToken(token: token)
        .acceptJson()
            .addHeader(name: "Authorization-Cad", value: cadService.getCadToken() ?? "")
    }
}

public protocol RealTimeService {
    func batchPublishLocation(_ positions: [PositionEventRecord], completion: @escaping (Result<NoContent, Error>) -> Void)
    func publishLocation(_ location: CLLocation, completion: @escaping (PositionEventRecord, Result<NoContent, Error>) -> Void)
    func switchToMyTeamStream()
    func switchToOperatingRegionsStream(ids: [UUID])
    func unsubscribe()
}

class RealTimeServiceImpl: StreamService, RealTimeService {
    enum RTConnectionState {
        case connectedToMyTeam, connectedToOperatingRegions, disconnected
    }
    
    static let shared = RealTimeServiceImpl()

    private let identityHeader: String?
    private var sseClient: EventSource?
    private let locationService = LocationService.shared

    var connectionState: RTConnectionState = .disconnected

    override init() {
        let containerDb = UserDefaults(suiteName: "serpro_data")
        identityHeader = containerDb?.string(forKey: "identity")
        super.init()
    }

    private func buildClient(url: URL) -> EventSource {
        var headers = [
            "Authorization": token,
            "Authorization-Cad": cadService.getCadToken() ?? ""
        ]
        if let userLocation = locationService.currentLocation {
            let coordinate = userLocation.coordinate
            headers["Geolocation"] = "\(coordinate.latitude),\(coordinate.longitude)"
        }
        return EventSource(
            url: url,
            headers: headers
        )
    }

    private func setupMyTeamClient() {
        sseClient?.disconnect()
        let eventsUrl = URL(string: "\(enviroment.host)/streams/api/positions/subscribe/my-team")!
        sseClient = buildClient(url: eventsUrl)
        sseClient?.onOpen {
            self.connectionState = .connectedToMyTeam
        }
        setupClient()
    }

    private func setupOperatingRegionsClient(ids: [UUID]) {
        sseClient?.disconnect()
        let queryParams = ids.map { "regions=\($0.uuidString)" }.joined(separator: "&")
        let eventsUrl = URL(string: "\(enviroment.host)/streams/api/positions/subscribe/regions?\(queryParams)")!
        sseClient = buildClient(url: eventsUrl)
        sseClient?.onOpen {
            self.connectionState = .connectedToOperatingRegions
        }
        setupClient()
    }

    private func setupClient() {
        sseClient?.onComplete { (statusCode, _, _) in
            self.connectionState = .disconnected
            if let statusCode = statusCode,
               let sseClient = self.sseClient,
               statusCode == 200 {
                sseClient.connect(lastEventId: sseClient.lastEventId)
            }
        }
    }

    private func decodePositionEvent(jsonString: String) -> PositionEvent? {
        let decoder = JSONDecoder()
        if let data = jsonString.data(using: .utf16),
           let positionEvent = try? decoder.decode(PositionEvent.self, from: data) {
            return positionEvent
        }
        return nil
    }
    
    private func connectAndSubstribe() {
        let notificationCenter = NotificationCenter.default
        sseClient?.connect()
        sseClient?.onMessage { (_, _, jsonString) in
            if let jsonString = jsonString,
               let positionEvent = self.decodePositionEvent(jsonString: jsonString) {
                notificationCenter.post(name: .realTimeReceivePosition, object: positionEvent)
            }
        }
    }

    func switchToMyTeamStream() {
        if connectionState != .connectedToMyTeam {
            setupMyTeamClient()
            connectAndSubstribe()
        }
    }

    func switchToOperatingRegionsStream(ids: [UUID]) {
        setupOperatingRegionsClient(ids: ids)
        connectAndSubstribe()
    }

    func unsubscribe() {
        sseClient?.disconnect()
    }

    func publishLocation(_ location: CLLocation, completion: @escaping (PositionEventRecord, Result<NoContent, Error>) -> Void) {
        if let activeTeamId = cadService.getActiveTeam()?.id,
           let identityHeader = identityHeader {
            let position = PositionEventRecord(
                teamId: activeTeamId,
                deviceId: identityHeader,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                eventTimestamp: Int(location.timestamp.timeIntervalSince1970 * 1000),
                accuracy: Float(location.horizontalAccuracy),
                equipmentId: cadService.getStoredEquipment()?.id
            )

            let rest = client
                .acceptJson()
                .path("/positions/publish")
                .ContentTypeJson()
                .body(position)
                .build()

            rest?.post(completion: { result in
                completion(position, result)
            })
        }
    }

    func batchPublishLocation(_ positions: [PositionEventRecord], completion: @escaping (Result<NoContent, Error>) -> Void) {
        let rest = client
            .acceptJson()
            .path("/positions/publish-batch")
            .ContentTypeJson()
            .body(positions)
            .build()

        rest?.post(completion: completion)
    }
}

@propertyWrapper
public struct RealTimeServiceInject {
    private var value: RealTimeService

    public init() {
        value = RealTimeServiceImpl.shared
    }

    public var wrappedValue: RealTimeService { value }
}
