//
//  DriverSearchService.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 13/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import RestClient
import Logger

enum DriverFilter {
    case cpf
    case cnh
    case renach
    case pid
}

public class DriverSearchService {

    var enviroment = ACEnviroment.shared
    var token: String {
        TokenService().getApplicationToken() ?? ""
    }

    public init() {}

    private func buildRest(filteringBy filter: DriverFilter, andValue value: String) -> RestTemplate? {
        let client = RestTemplateBuilder(enviroment: enviroment)
        var restBuilder: RestTemplateBuilder!
        switch filter {
        case .cpf:
            restBuilder = client.path("/search/conductors/cpf/\(value.onlyStandardCharacters())")
        case .cnh:
            restBuilder = client.path("/search/conductors/registration/\(value.onlyStandardCharacters())")
        case .renach:
            restBuilder = client.path("/search/conductors/renach/\(value.onlyStandardCharacters())")
        case .pid:
            restBuilder = client.path("/search/conductors/pid/\(value.onlyStandardCharacters())")
        }

        return restBuilder.addToken(token: token).build()
    }

    public func getDriversByCpf(_ cpf: String, completion: @escaping (Result<[Driver], Error>) -> Void) {
        let rest = buildRest(filteringBy: .cpf, andValue: cpf)
        rest?.get(completion: completion)
    }

    public func getDriversByCnh(_ cnh: String, completion: @escaping (Result<[Driver], Error>) -> Void) {
        let rest = buildRest(filteringBy: .cnh, andValue: cnh)
        rest?.get(completion: completion)
    }

    public func getDriversByRenach(_ renach: String, completion: @escaping (Result<[Driver], Error>) -> Void) {
        let rest = buildRest(filteringBy: .renach, andValue: renach)
        rest?.get(completion: completion)
    }

    public func getDriversByPid(_ pid: String, completion: @escaping (Result<[Driver], Error>) -> Void) {
        let rest = buildRest(filteringBy: .pid, andValue: pid)
        rest?.get(completion: completion)
    }
}
