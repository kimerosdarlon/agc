//
//  ApplicationErrors.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 21/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct ApplicationErrors: Equatable {
    public let code: Int
    public let message: String
    public static let documentIsEmpty = ApplicationErrors(code: 100, message: "Preencha o campo do número do documento")
    public static let cityIsEmpty = ApplicationErrors(code: 101, message: "Selecione uma cidade")
    public static let paramsIsEmpty = ApplicationErrors(code: 102, message: "Você deve preencher pelo menos um filtro para realizar a busca.")
    public static let cityAndStateOnly = ApplicationErrors(code: 102, message: "Estado ou município deve ser composto com outro filtro.")
}
