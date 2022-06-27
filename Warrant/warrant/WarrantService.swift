//
//  WarrantService.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 08/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import RestClient
import AgenteDeCampoCommon
import Logger

class Service {
    var enviroment = ACEnviroment.shared
    var token: String {
        TokenService().getApplicationToken() ?? ""
    }
}

class WarrantService: Service {
    lazy var logger = Logger.forClass(Self.self)
    func findBy(search string: String, completion: @escaping (Result<[Warrant], Error>) -> Void ) {
        let params = [
            "name": string.onlyStandardCharacters(),
            "page": "0",
            "size": "50"
        ]
        findBy(search: params, completion: completion)
    }

    func findBy(search params: [String: Any], completion: @escaping (Result<[Warrant], Error>) -> Void ) {
        let client = RestTemplateBuilder(enviroment: enviroment)
        let rest = client.path("/search/warrants").addToken(token: token).acceptJson().params(params)
            .build()
        logger.debug(rest?.request.url?.absoluteString ?? "")
        rest?.get(completion: completion)
    }

    func getDetails(_ warrant: Warrant, completion: @escaping (Result<WarrantDetails, Error>) -> Void) {
        let client = RestTemplateBuilder(enviroment: enviroment)
        let identifier = warrant.id
        let type = warrant.type.id
        let rest = client.path("/search/warrants/\(type)/\(identifier)").addToken(token: token).acceptJson()
            .build()
        logger.debug(rest?.request.url?.absoluteString ?? "")
        rest?.get(completion: completion)
    }
}
