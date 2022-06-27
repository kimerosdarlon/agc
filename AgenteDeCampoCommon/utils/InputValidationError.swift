//
//  InputValidationError.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 29/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public enum InputValidationError: String, CustomStringConvertible, Error {
    case cpf = "CPF inválido"
    case cnpj = "CNPJ inválido"
    case cnh = "CNH inválida"
    case renach = "Renach inválido"
    case pid = "PID inválido"
    case plate = "A placa está no formato errado"
    case date = "A data informada está no formato errado"
    case invalidDate = "A data informada não é válida"
    case chassis = "O Chassi precisa ter 17 dígitos"
    case empty = "Você precisa preencher pelo menos um filtro"
    case `protocol` = "O protocolo deve ter entre 19 e 35 dígitos."

    public var description: String {
        return self.rawValue
    }
}
