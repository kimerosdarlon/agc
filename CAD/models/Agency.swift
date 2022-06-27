//
//  Agency.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct Agency: Codable, Hashable {
    public let name: String
    public let initials: String
    public let id: String

    public static func == (lhs: Agency, rhs: Agency) -> Bool {
        lhs.id == rhs.id
    }
}
