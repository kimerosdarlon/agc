//
//  FinishTeam.swift
//  CAD
//
//  Created by Samir Chaves on 20/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation

public struct FinishTeam: Codable {
    public let reason: String
    public let equipments: [EquipmentKm]
}
