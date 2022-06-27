//
//  Notification+extension.swift
//  Location
//
//  Created by Samir Chaves on 19/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public extension Notification.Name {
    static let userLocationStatusDidChange = Notification.Name.init("userLocationStatusDidChange")
    static let userLocationDidChange = Notification.Name.init("userLocationDidChange")
    static let userHeadingDidChange = Notification.Name.init("userHeadingDidChange")
    static let didUserEnterRegion = Notification.Name.init("didUserEnterRegion")
    static let didUserExitRegion = Notification.Name.init("didUserExitRegion")
}
