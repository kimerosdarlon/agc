//
//  CadResource.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct CadResource: Codable {
    public let resource: PersonProfile
    public let cadToken: String
    public let dispatches: [TeamDispatch]?
}
