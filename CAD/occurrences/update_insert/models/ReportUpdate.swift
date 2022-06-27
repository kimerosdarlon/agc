//
//  ReportUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 21/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct ReportUpdate: Codable {
    var teamId: UUID
    var report: String
}
