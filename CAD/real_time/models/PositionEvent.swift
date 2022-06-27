//
//  PositionEvent.swift
//  CAD
//
//  Created by Samir Chaves on 05/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

struct PositionEvent: Codable {
    let uuid: UUID
    let cpf: String
    let teamId: UUID
    let deviceId: String
    let latitude: Double
    let longitude: Double
    let eventTimestamp: Int
    let receivedAt: Int
    let equipmentId: UUID?
    let accuracy: Float?
}
