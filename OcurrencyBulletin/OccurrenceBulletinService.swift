//
//  OccurrenceBulletinService.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 22/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import RestClient
import AgenteDeCampoCommon
import Logger

class OccurrenceBulletinService {
    private lazy var logger = Logger.forClass(Self.self)

    func getInvolved(params: [String: Any], type: ServiceType, completion: @escaping (Result<[BulletinItem], Error>) -> Void ) {
        if params.isEmpty {
            let error = ApplicationErrors.paramsIsEmpty
            completion(.failure( NSError(domain: error.message, code: error.code, userInfo: nil) ))
            return
        }
        guard let token = TokenService().getApplicationToken() else {
            completion(.failure(RequestError.invalidToken))
            return
        }
        var params = params
        let builder = RestTemplateBuilder.init(enviroment: ACEnviroment.shared)
        params["page.page"] = 0
        params["page.size"] = 100
        params["service"] = nil
        let rest = builder.acceptJson().path("/search/bulletins/involved/\(type.rawValue)").params(params).acceptJson()
            .addToken(token: token).build()
        self.logger.debug(rest?.request.url?.absoluteString ?? "")
        rest?.get(completion: completion)
    }

    func getDetails(id: Int, completion: @escaping (Result<BulletinDetails, Error>) -> Void ) {
        guard let token = TokenService().getApplicationToken() else {
            completion(.failure(RequestError.invalidToken))
            return
        }
        let builder = RestTemplateBuilder.init(enviroment: ACEnviroment.shared)

        let rest = builder.acceptJson().path("/search/bulletins/\(id)").acceptJson()
            .addToken(token: token).build()
        self.logger.debug(rest?.request.url?.absoluteString ?? "")
        rest?.get(completion: completion)
    }

    func getByNationalCode(code: String, completion: @escaping (Result<BulletinDetails, Error>) -> Void) {

        guard let token = TokenService().getApplicationToken() else {
            completion(.failure(RequestError.invalidToken))
            return
        }
        let builder = RestTemplateBuilder.init(enviroment: ACEnviroment.shared)
        let rest = builder.acceptJson().path("/search/bulletins/national/\(code)").acceptJson()
            .addToken(token: token).build()
        self.logger.debug(rest?.request.url?.absoluteString ?? "")
        rest?.get(completion: completion)
    }

    func getByStateCode(state: String, code: String, completion: @escaping (Result<BulletinDetails, Error>) -> Void) {

        guard let token = TokenService().getApplicationToken() else {
            completion(.failure(RequestError.invalidToken))
            return
        }
        let builder = RestTemplateBuilder.init(enviroment: ACEnviroment.shared)
        let rest = builder.acceptJson().path("/search/bulletins/state/\(state)/\(code)").acceptJson()
            .addToken(token: token).build()
        self.logger.debug(rest?.request.url?.absoluteString ?? "")
        rest?.get(completion: completion)
    }

    func getByObject(params: [String: Any], type: ServiceType, completion: @escaping (Result<[BulletinItem], Error>) -> Void ) {

        if params.isEmpty {
            let error = ApplicationErrors.paramsIsEmpty
            completion(.failure( NSError(domain: error.message, code: error.code, userInfo: nil) ))
            return
        }
        guard let token = TokenService().getApplicationToken() else {
            completion(.failure(RequestError.invalidToken))
            return
        }
        var params = params
        params["service"] = nil
        let builder = RestTemplateBuilder.init(enviroment: ACEnviroment.shared)
        params["page.page"] = 0
        params["page.size"] = 100
        let rest = builder.acceptJson().path("/search/bulletins/\(type.rawValue)").params(params).acceptJson()
            .addToken(token: token).build()
        self.logger.debug(rest?.request.url?.absoluteString ?? "")
        rest?.get(completion: completion)
    }
}
