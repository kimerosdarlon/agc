//
//  OperacionalBreak.swift
//  CAD
//
//  Created by Ramires Moreira on 04/09/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct OperationalServiceResponse: Codable {
    public let operationalBreak: OperationalBreak?
}

public struct OperationalBreak: Codable {
    public let registerDateTime: String
}
