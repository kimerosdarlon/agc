//
//  DispatchReleaseCmd.swift
//  CAD
//
//  Created by Samir Chaves on 01/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct DispatchReleaseCmd: Codable {
    let category: String?
    let reason: String?
    let description: String?
    let online: Bool

    init(category: String?, reason: String?, description: String?, online: Bool) {
        self.category = category
        self.reason = reason
        self.description = description
        self.online = online
    }
}
