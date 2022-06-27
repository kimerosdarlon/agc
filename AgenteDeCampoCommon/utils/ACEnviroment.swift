//
//  Constants.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import RestClient
import SinespSegurancaAuthMobile

public enum Configuration {
    public enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    public static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

public enum ACEnviroment: String, RestConfiguration {
    case dev
    case production
    case stage

    public static var shared: ACEnviroment {
        guard let enviroment: String = try? Configuration.value(for: "ENVIROMENT") else { return .dev }
        return ACEnviroment.init(rawValue: enviroment) ?? .dev
    }

    public var debug: Bool {
        switch self {
        case .dev:
            return false
        case .production:
            return false
        case .stage:
            return false
        }
    }

    public var appServerKey: String {
        let key = Bundle.main.object(forInfoDictionaryKey: "API_SERVER_KEY") as! String
        return key
    }
    
    public var systemInitials: String {
        guard let initials: String = try? Configuration.value(for: "SYSTEM_INITIALS") else { return "" }
        return initials
    }
    
    public var identitySecret: String {
        guard let secret: String = try? Configuration.value(for: "IDENTITY_HEADER_SECRET") else { return "" }
        return secret
    }
    
    public var identitySalt: String {
        guard let salt: String = try? Configuration.value(for: "IDENTITY_HEADER_SALT") else { return "" }
        return salt
    }

    public var app: String {
        guard let initials: String = try? Configuration.value(for: "APP") else { return "" }
        return initials
    }

    public var appName: String {
        guard let initials: String = try? Configuration.value(for: "APP_NAME") else { return "" }
        return initials
    }

    public var appVersion: String {
        guard let initials: String = try? Configuration.value(for: "APP_VERSION") else { return "" }
        return initials
    }

    public var host: String {
        guard let appHost: String = try? Configuration.value(for: "HOST") else { return "" }
        guard let schema: String = try? Configuration.value(for: "SCHEMA") else { return "" }
        return "\(schema)://\(appHost)"
    }

    public var privacyPoliciesHost: String {
        guard let appHost: String = try? Configuration.value(for: "PRIVACY_POLICIES_LINK") else { return "" }
        guard let schema: String = try? Configuration.value(for: "SCHEMA") else { return "" }
        return "\(schema)://\(appHost)"
    }

    public var securityEnv: Enviroment {
        switch self {
        case .dev:
            return .stage
        case .production:
            return .production
        case .stage:
            return .stage
        }
    }

    public var logApppId: String {
        guard let appId = try? Configuration.value(for: "LOG_APP_ID") as String else {
            return ""
        }
        return appId
    }

    public var logAppSecret: String {
        guard let appId = try? Configuration.value(for: "LOG_APP_SECRET") as String else {
            return ""
        }
        return appId
    }

    public var logEncryptionKey: String {
        guard let appId = try? Configuration.value(for: "LOG_ENCRYPTION_KEY") as String else {
            return ""
        }
        return appId
    }
}
