//
//  OccurrencePushNotification.swift
//  CAD
//
//  Created by Samir Chaves on 27/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon

public struct OccurrencePushNotification: Codable, PushNotificationModel {
    public let dispatch: Dispatch
    public let occurrenceDetails: OccurrenceDetails

    public static func fromDict(_ dataDict: [String: Any]) -> OccurrencePushNotification? {
        dataDict.object()
    }
}

public struct OccurrenceAddress: Codable {
    public let street: String?
    public let district: String?
    public let city: String
    public let state: String
    public let addressType: String?
    public let latitude: Double
    public let longitude: Double
}
