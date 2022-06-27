//
//  StateDataSourceMock.swift
//  OcurrencyBulletinUnitTests
//
//  Created by Ramires Moreira on 26/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
@testable import CoreDataModels

class StateDataSourceMock: StateDataSource {

    override func findByInitials(_ initials: String) -> State? {
        return State(initials: "CE", name: "Ceará", cities: [
            City(name: "Fortaleza", code: 123)])
    }
}
