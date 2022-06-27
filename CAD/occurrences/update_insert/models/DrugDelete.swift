//
//  DrugDelete.swift
//  CAD
//
//  Created by Samir Chaves on 15/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct DrugDelete: Codable {
    let externalId: UUID?
    let teamId: UUID
    let drugs: [IdVersion]
}
