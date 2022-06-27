//
//  TeamPerson.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct TeamPerson: Codable, Hashable {
    public let role: Role
    public let person: Person

    public func hash(into hasher: inout Hasher) {
        hasher.combine(person.id)
    }

    public static func == (lhs: TeamPerson, rhs: TeamPerson) -> Bool {
        return lhs.person.id == rhs.person.id
    }

    public func toSimple() -> SimpleTeamPerson {
        return SimpleTeamPerson(role: role, person: person.toSimple())
    }
}

public struct SimpleTeamPerson: Codable, Hashable {
    public let role: Role
    public let person: SimplePerson

    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(role.id.uuidString)_\(person.name)")
    }

    public static func == (lhs: SimpleTeamPerson, rhs: SimpleTeamPerson) -> Bool {
        return "\(lhs.role.id.uuidString)_\(lhs.person.name)" == "\(rhs.role.id.uuidString)_\(rhs.person.name)"
    }
}
