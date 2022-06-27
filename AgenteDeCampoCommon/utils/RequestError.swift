//
//  RequestError.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 12/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public enum RequestError: String, CustomStringConvertible, Error {
    case invalidToken = "O token utilizado para realizar a requisição está inválido"
    case invalidText = "O termo da busca não está formatado corretamente"

    public var description: String {
        return self.rawValue
    }
}
