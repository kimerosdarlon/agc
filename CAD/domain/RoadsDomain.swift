//
//  RoadsDomain.swift
//  CAD
//
//  Created by Samir Chaves on 18/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct RoadsDomain: Codable {
    let lanes: [DomainValue]
    let roadways: [DomainValue]
    let types: [DomainValue]
}
