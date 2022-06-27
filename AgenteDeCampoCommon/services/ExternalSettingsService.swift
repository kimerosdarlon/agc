//
//  ExternalSettingsService.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 20/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import RestClient

public struct VersionSettings: Codable {
    public let build: Int
    public let version: String

    init() {
        let dictionary = Bundle.main.infoDictionary!
        let build = dictionary["CFBundleVersion"] as! String
        self.build = Int(build) ?? 0
        self.version = ACEnviroment.shared.appVersion
    }
}

public struct RealTimeSettings: Codable {
    public var radiusSize: Int {
        didSet {
            UserDefaults.standard.set(radiusSize, forKey: "realtime-settings-radius")
        }
    }
    public let positionCollectionInterval: TimeInterval
    public let dispatchedTeamPositionCollectionInterval: TimeInterval
    public let positionsCleanTimeout: TimeInterval
    public let dispatchInDisplacementRadius: Int
    public let dispatchArrivalRadius: Int

    public static let `default` = RealTimeSettings(
        radiusSize: 1000,
        positionCollectionInterval: 60000,
        dispatchedTeamPositionCollectionInterval: 30000,
        positionsCleanTimeout: 180000,
        dispatchInDisplacementRadius: 50,
        dispatchArrivalRadius: 50
    )

    struct Optional: Codable {
        let radiusSize: Int?
        let positionCollectionInterval: TimeInterval?
        let dispatchedTeamPositionCollectionInterval: TimeInterval?
        let positionsCleanTimeout: TimeInterval?
        let dispatchInDisplacementRadius: Int?
        let dispatchArrivalRadius: Int?

        func get() -> RealTimeSettings {
            let defaultConfig = RealTimeSettings.default
            return RealTimeSettings(
                radiusSize: radiusSize ?? defaultConfig.radiusSize,
                positionCollectionInterval: positionCollectionInterval ?? defaultConfig.positionCollectionInterval,
                dispatchedTeamPositionCollectionInterval: dispatchedTeamPositionCollectionInterval ?? defaultConfig.dispatchedTeamPositionCollectionInterval,
                positionsCleanTimeout: positionsCleanTimeout ?? defaultConfig.positionsCleanTimeout,
                dispatchInDisplacementRadius: dispatchInDisplacementRadius ?? defaultConfig.dispatchInDisplacementRadius,
                dispatchArrivalRadius: dispatchArrivalRadius ?? defaultConfig.dispatchArrivalRadius
            )
        }
    }
}

public struct ExternalSettings: Codable {
    public let ios: VersionSettings
    public let realTime: RealTimeSettings

    struct Optional: Codable {
        let ios: VersionSettings
        let realTime: RealTimeSettings.Optional

        func get() -> ExternalSettings {
            ExternalSettings(ios: ios, realTime: realTime.get())
        }
    }
}

public class ExternalSettingsService {
    private var enviroment = ACEnviroment.shared
    private var token: String {
        TokenService().getApplicationToken() ?? ""
    }

    private var client: RestTemplateBuilder {
        return RestTemplateBuilder(enviroment: self.enviroment)
            .addToken(token: token)
            .acceptJson()
    }

    public init() {}

    public static var settings = ExternalSettings(
        ios: VersionSettings(),
        realTime: RealTimeSettings.default
    )

    public func fetchSettings(completion: @escaping (Error?) -> Void) {
        let rest = client.path("/base-configurations")
            .build()
        rest?.get(completion: { (result: Result<ExternalSettings.Optional, Error>) in
            switch result {
            case .success(let settings):
                ExternalSettingsService.settings = settings.get()
                completion(nil)
            case .failure(let error):
                ExternalSettingsService.settings = self.defaultSettings()
                completion(error)
            }
        })
    }

    private func defaultSettings() -> ExternalSettings {
        return ExternalSettings(
            ios: VersionSettings(),
            realTime: RealTimeSettings.default
        )
    }
}
