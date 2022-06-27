//
//  WeaponDomain.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct WeaponsDomain: Codable {
    let species: [DomainValue]
    let manufactures: [DomainValue]
    let calibers: [DomainValue]
    let situations: [DomainValue]
    let involvedLinks: [DomainValue]
    let models: [DomainValue]
    let brands: [DomainValue]
    let types: [DomainValue]
    let destinations: [DomainValue]

    enum CodingKeys: String, CodingKey {
        case species
        case manufactures
        case calibers
        case situations
        case involvedLinks = "involved-links"
        case models
        case brands
        case types
        case destinations
    }
}
