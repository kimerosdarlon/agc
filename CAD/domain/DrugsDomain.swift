//
//  DrugsDomain.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct DrugsDomain: Codable {
    let packaging: [DomainValue]
    let apparentTypes: [DomainValue]
    let situations: [DomainValue]
    let involvedLinks: [DomainValue]
    let unitiesOfMeasure: [DomainValue]
    let destinations: [DomainValue]

    enum CodingKeys: String, CodingKey {
        case packaging
        case apparentTypes = "apparent-types"
        case situations
        case involvedLinks = "involved-links"
        case unitiesOfMeasure = "unities-of-measure"
        case destinations
    }
}
