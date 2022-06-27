//
//  Places.swift
//  CAD
//
//  Created by Samir Chaves on 04/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct State: Codable {
    public let id: String
    public let initials: String
    public let name: String
    public let ibgeCode: Int

    static public let empty = State(id: "", initials: "", name: "", ibgeCode: -1)
}

public struct StateWithCities: Codable {
    public let id: String
    public let initials: String
    public let name: String
    public let ibgeCode: Int
    public let cities: [City]

    public func withoutCity() -> State {
        return State(id: id, initials: initials, name: name, ibgeCode: ibgeCode)
    }
}

public struct City: Codable {
    public let ibgeCode: Int
    public let name: String
    public let stateId: String
}
