//
//  PushNotificationModel.swift
//  CAD
//
//  Created by Samir Chaves on 15/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

protocol PushNotificationModel {
    static func fromDict(_ dataDict: [String: Any]) -> Self?
}
