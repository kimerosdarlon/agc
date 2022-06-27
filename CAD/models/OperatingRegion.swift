//
//  OperatingRegion.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct OperatingRegion: Codable, Hashable {
    public let description: String
    public let name: String
    public let initials: String
    public let id: UUID
    public let agency: Agency

    public static func == (lhs: OperatingRegion, rhs: OperatingRegion) -> Bool {
        lhs.id == rhs.id
    }
}
