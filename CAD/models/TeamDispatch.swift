//
//  TeamDispatch.swift
//  CAD
//
//  Created by Samir Chaves on 08/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation

public struct TeamDispatch: Codable {
    public let dateTime: String
    public let timeZone: String
    public let `operator`: Operator
    public let report: String?
    public let status: String
    public let statusCode: DispatchStatusCode
    public let occurrenceId: UUID

    public func toDispatch(team: Team) -> Dispatch {
        Dispatch(dateTime: dateTime,
                 team: team.toSimpleTeam(),
                 timeZone: timeZone,
                 operator: `operator`,
                 report: report,
                 status: status)
    }
}
