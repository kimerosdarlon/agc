//
//  InvolvedDomain.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public class InvolvedsDomain: Codable {
    let sexes: [DomainValue]
    let races: [DomainValue]
    let documentTypes: [DomainValue]
    let involvements: [DomainValue]

    enum CodingKeys: String, CodingKey {
        case sexes
        case races
        case documentTypes = "document-types"
        case involvements
    }
}
