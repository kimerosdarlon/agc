//
//  DispatchReleaseReason.swift
//  CAD
//
//  Created by Samir Chaves on 02/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct DispatchReleaseReason: Codable {
    let code: String
    let description: String
    let finishReasons: [FinishReason]
}

public struct FinishReason: Codable {
    let code: String
    let description: String
    let requiresDescription: Bool
}
