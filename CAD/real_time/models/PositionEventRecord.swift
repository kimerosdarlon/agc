//
//  PositionEventRecord.swift
//  CAD
//
//  Created by Samir Chaves on 06/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct PositionEventRecord: Codable {
    let teamId: UUID
    let deviceId: String
    let latitude: Double
    let longitude: Double
    let eventTimestamp: Int
    let accuracy: Float
    let equipmentId: UUID?
}
