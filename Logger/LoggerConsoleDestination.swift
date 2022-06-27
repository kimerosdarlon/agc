//
//  LoggerConsoleDestination.swift
//  Logger
//
//  Created by Ramires Moreira on 13/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import SwiftyBeaver
import Pods_SinespAgenteCampo_AppModules_AgenteDeCampoCommon

public class LoggerConsoleDestination: Destination {

    public var level: LoggerLevel
    public init(level: LoggerLevel) {
        self.level = level
    }

    public func send(message: String, level: LoggerLevel) {
        #if DEBUG
            print(message)
        #endif
//        let platform = SBPlatformDestination(appID: logApppId, appSecret: logAppSecret, encryptionKey: logEncryptionKey)
//        SwiftyBeaver.addDestination(ConsoleDestination())
//        SwiftyBeaver.addDestination(platform)
//        SwiftyBeaver.debug(message)
    }

    var logApppId: String {
        guard let appId = try? Configuration.value(for: "LOG_APP_ID") as String else {
            return ""
        }
        return appId
    }

    var logAppSecret: String {
        guard let appId = try? Configuration.value(for: "LOG_APP_SECRET") as String else {
            return ""
        }
        return appId
    }

    var logEncryptionKey: String {
        guard let appId = try? Configuration.value(for: "LOG_ENCRYPTION_KEY") as String else {
            return ""
        }
        return appId
    }
}

enum Configuration {
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
