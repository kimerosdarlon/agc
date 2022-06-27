//
//  User.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 13/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import SinespSegurancaAuthMobile

public struct Organization: Codable {
    public let id: Int
    public let name: String
    public let state: String
    public let city: String
    public let cityIbgeCode: Int
}

public struct User {

    public let email: String
    public let cpf: String
    public let name: String
    public let id: String
    public let organization: Organization
    public let has2FA: Bool
    public let image: String?
    public let roles: [String]

    public init(with model: LoginModel) {
        self.roles = model.usuario?.roles ?? []
        self.email = model.usuario?.nome ?? ""
        self.cpf = model.usuario?.nome ?? ""
        self.name = model.usuario?.nome ?? ""
        id = ""
        self.organization = Organization(
            id: model.usuario?.eoOrigem?.id ?? 0,
            name: model.usuario?.eoOrigem?.nome ?? "",
            state: model.usuario?.eoOrigem?.endereco.uf.sigla ?? "",
            city: model.usuario?.eoOrigem?.endereco.municipio.nome ?? "",
            cityIbgeCode: model.usuario?.eoOrigem?.endereco.municipio.codigoIBGE ?? 0
        )
        self.has2FA = false
        self.image = model.usuario?.foto
    }

    public var canSeeVehiclesTrack: Bool {
        return roles.contains(Roles.vehicleTrack)
    }

    public func has(role: String) -> Bool {
        return roles.contains(role)
    }
}
