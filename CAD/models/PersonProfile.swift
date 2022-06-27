//
//  PersonProfile.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct PersonProfile: Codable {
    public let person: Person
    public let activeTeam: UUID?
    public let teams: [Team]

    public func getActiveTeam() -> Team? {
        teams.first(where: { $0.id == activeTeam })
    }
}
