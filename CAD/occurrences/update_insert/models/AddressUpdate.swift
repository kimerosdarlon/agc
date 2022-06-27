//
//  AddressUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 17/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct AddressUpdate: Codable {
    var address: LocationUpdate
    let teamId: UUID
}

struct LocationUpdate: Codable {
    var district: String?
    var ibgeCityCode: String?
    var complement: String?
    var coordinates: LocationCoordinates?
    var km: String?
    var street: String?
    var city: String?
    var number: String?
    var highwayLane: String?
    var referencePoint: String?
    var highway: String?
    var roadDirection: String?
    var placeType: Int?
    var roadType: String?
    var stretch: String?
    var state: String?
    var version: Int
}

struct LocationUpdateForm: Codable {
    var district: String?
    var ibgeCityCode: String?
    var complement: String?
    var coordinates: LocationCoordinates?
    var km: String?
    var street: String?
    var city: String?
    var number: String?
    var highwayLane: String?
    var referencePoint: String?
    var highway: String?
    var roadDirection: String?
    var placeType: Int?
    var roadType: String?
    var stretch: String?
    var state: String?
    var version: Int
}
