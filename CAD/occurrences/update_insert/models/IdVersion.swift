//
//  IdVersion.swift
//  CAD
//
//  Created by Samir Chaves on 13/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct IdVersion: Codable {
    var id: UUID
    var version: Int
}
