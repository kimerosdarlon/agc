//
//  IntermediatePlace.swift
//  CAD
//
//  Created by Samir Chaves on 17/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct IntermediatePlace: Codable, Hashable {
    let code: String
    let description: String
    let requiresDescription: Bool

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    public static func == (lhs: IntermediatePlace, rhs: IntermediatePlace) -> Bool {
        return lhs.code == rhs.code
    }
}
