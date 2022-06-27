//
//  WeaponDelete.swift
//  CAD
//
//  Created by Samir Chaves on 15/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct WeaponDelete: Codable {
    let externalId: UUID?
    let teamId: UUID
    let weapons: [IdVersion]
}
