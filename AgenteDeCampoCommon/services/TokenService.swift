//
//  TokenService.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 22/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import SinespSegurancaAuthMobile

public class TokenService {

    public init() {
    }

    public func saveAllToken(_ model: LoginModel) {

        if let token = model.token {
            saveToken(token)
        }

        if let grantToken = model.token {
            saveGrantToken(grantToken)
        }

        if let appToken = model.token {
            saveApplication(appToken)
        }
    }

    public func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "token")
    }

    public func saveApplication(_ token: String) {
        UserDefaults.standard.set(token, forKey: "applicationToken")
    }

    public func saveGrantToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "grantToken")
    }

    public func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "token")
    }

    public func getApplicationToken() -> String? {
        return UserDefaults.standard.string(forKey: "applicationToken")
    }

    public func getGrantToken() -> String? {
        return UserDefaults.standard.string(forKey: "grantToken")
    }

    public func clearAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "grantToken")
        defaults.removeObject(forKey: "applicationToken")
    }
}
