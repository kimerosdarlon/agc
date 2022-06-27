//
//  VehicleDomain.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct VehiclesDomain: Codable {
    let escaped: [DomainValue]
    let moveCondition: [DomainValue]
    let involvements: [DomainValue]
    let involvedLinks: [DomainValue]

    enum CodingKeys: String, CodingKey {
        case escaped
        case moveCondition = "move-condition"
        case involvements
        case involvedLinks = "involved-links"
    }
}
