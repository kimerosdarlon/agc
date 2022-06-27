//
//  StartService.swift
//  CAD
//
//  Created by Ramires Moreira on 04/09/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct StartService: Codable {
    public let activate: ActivateTeam
    public let checklistReply: ReplyFormSeed
}

public struct ReplyFormSeed: Codable {
    public let responses: [Response]
}
