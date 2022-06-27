//
//  OperationalBreakPushNotification.swift
//  CAD
//
//  Created by Samir Chaves on 15/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

struct OperationalBreakPushNotification: Decodable, PushNotificationModel {
    let paused: Bool
    let dateTime: String
    let breakType: String?
    let observations: String?
    let equipments: [Equipment]
    let operationalBreakTypeDescription: String?

    struct Equipment: Decodable {
        let id: UUID
        let prefix: String
        let kmSupply: Int?
    }

    static func fromDict(_ dataDict: [String: Any]) -> OperationalBreakPushNotification? {
        dataDict.object()
    }
}
