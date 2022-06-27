//
//  VehicleService.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 28/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import RestClient
import AgenteDeCampoCommon

public class VehicleService {
    public init() { }

    public func findBy(search term: String, completion: @escaping (Result<[VehicleResult], Error>) -> Void ) {
        findBy(params: getQueryParams(for: term), completion: completion)
    }

    func findBy(params: [String: Any], completion: @escaping (Result<[VehicleResult], Error>) -> Void ) {
        guard let token =  TokenService().getApplicationToken() else {
            completion(.failure(RequestError.invalidToken))
            return
        }

        if params.count < 2 {
            completion(.failure(RequestError.invalidText))
            return
        }
        let rest = RestTemplateBuilder(enviroment: ACEnviroment.shared)
            .addToken(token: token).acceptJson().path("/search/vehicles")
            .params(params).build()
        rest?.get(completion: completion)
    }

    func track(plate: String, completion: @escaping (Result<[VehicleLocation], Error>) -> Void ) {
        guard let token =  TokenService().getApplicationToken() else {
            completion(.failure(RequestError.invalidToken))
            return
        }
        RestTemplateBuilder(enviroment: ACEnviroment.shared)
            .addToken(token: token).acceptJson()
            .path("/search/vehicles/\(plate.onlyStandardCharacters())/track")
            .build()?
            .get(completion: completion)
    }

    fileprivate func getQueryParams(for text: String) -> [String: Any] {
        var type: String!
        if text.matches(in: AppRegex.cpfPattern) {
            type = "owner"
        } else {
            AppRegex.platePatterns.forEach({ pattern in
                if text.matches(in: pattern ) {
                    type = "plate"
                }
            })
        }
        guard let typeResult = type else { return [:] }

        let param = ["type": typeResult, typeResult: text.onlyStandardCharacters() ]
        return param
    }
}
