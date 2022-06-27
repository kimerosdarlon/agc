//
//  DispatchUpdateCmd.swift
//  CAD
//
//  Created by Samir Chaves on 31/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

struct DispatchUpdateCmd: Codable {
    let status: String
    let intermediatePlace: String?
    let description: String?
}
