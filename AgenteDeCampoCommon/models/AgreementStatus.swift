//
//  AgreementStauts.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 30/09/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct Agreement: Codable {
    public let id: Int
    public let dateTime: String
    public let userCpf: String
    public let organization: Organization
}

public struct AgreementStatus: Codable {
    public let agreed: Bool
    public let agreement: Agreement?
}
