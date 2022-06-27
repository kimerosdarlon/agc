//
//  Damin.swift
//  CAD
//
//  Created by Samir Chaves on 11/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct DomainValue: Codable, Hashable {
    let option: String
    let label: String
    let group: [String]?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(option)
    }

    public static func == (lhs: DomainValue, rhs: DomainValue) -> Bool {
        lhs.option == rhs.option
    }
}
