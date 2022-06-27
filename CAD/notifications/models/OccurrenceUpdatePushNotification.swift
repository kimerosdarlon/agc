//
//  OccurrenceUpdatePushNotification.swift
//  CAD
//
//  Created by Samir Chaves on 17/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public struct OccurrenceUpdatePushNotification: Codable, PushNotificationModel {
    public let array: [OccurrenceUpdateItem]

    public static func fromDict(_ dataDict: [String: Any]) -> OccurrenceUpdatePushNotification? {
        dataDict.object()
    }
}

public struct OccurrenceUpdateItem: Codable {
    public let key: String
    public let value: String
}
