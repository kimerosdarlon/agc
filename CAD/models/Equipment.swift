//
//  Equipment.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct GroupEquipment: Codable {
    public let id: UUID
    public let name: String
}

public struct Equipment: Codable, Hashable {
    public let agency: Agency
    public let kmAllowed: Bool
    public let km: Int?
    public let groupEquipment: GroupEquipment?
    public let brand: String?
    public let model: String?
    public let plate: String?
    public let prefix: String?
    public let type: EquipmentType
    public let id: UUID

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Equipment, rhs: Equipment) -> Bool {
        return lhs.id == rhs.id
    }

    public func formatName() -> String {
        return String.interpolateString(
            values: [brand, model, prefix, plate],
            separators: [" / ", " - ", " - "]
        )
    }
}

public struct EquipmentKm: Codable {
    public let km: String?
    public let id: UUID
}
