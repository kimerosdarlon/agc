//
//  PrivacyPoliciesServiceViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 18/09/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import RestClient
import Logger

public class ConfidentialityService {
    var enviroment = ACEnviroment.shared
    var token: String {
        TokenService().getApplicationToken() ?? ""
    }

    public init() { }

    public func agreeTerms(completion: @escaping (Result<NoContent, Error>) -> Void) {
        let client = RestTemplateBuilder(enviroment: enviroment)
        let rest = client.path("/terms/agree")
            .addToken(token: token)
            .acceptJson()
            .build()
        rest?.post(completion: completion)
    }

    public func checkAgreetment(completion: @escaping (Result<AgreementStatus, Error>) -> Void) {
        let client = RestTemplateBuilder(enviroment: enviroment)
        let rest = client.path("/terms/agreement")
            .addToken(token: token)
            .acceptJson()
            .build()
        rest?.get(completion: completion)
    }
}
