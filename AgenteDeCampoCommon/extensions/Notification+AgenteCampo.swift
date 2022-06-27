//
//  Notification+AgenteCampo.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 30/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
public extension Notification {

    var keyboardSize: CGRect {
        guard let info = userInfo else {return .zero}
        return info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
    }
}

public extension Notification.Name {
    static let clearRecents = Notification.Name.init("clearRecents")
    static let loginErrorMessage = Notification.Name.init("loginErrorMessage")
    static let actionNavigation = Notification.Name.init("actionNavigation")
    static let updateBadgeCount = Notification.Name.init("updateBadgeCount")
    static let userUnauthenticated = Notification.Name.init("userUnauthenticated")
}
