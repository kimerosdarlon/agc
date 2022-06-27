//
//  Person.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct Person: Codable, Hashable {

    public let agency: Agency
    public var role: String
    public let cpf: String
    public let registration: String
    public var name: String
    public let functionalName: String
    public let cellphone: String?
    public let telephone: String?
    public var id: UUID

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }

    public func toSimple() -> SimplePerson {
        SimplePerson(role: role, cpf: cpf, name: name, functionalName: functionalName)
    }
}

public struct SimplePerson: Codable {
    public var role: String
    public let cpf: String?
    public var name: String
    public let functionalName: String
}
