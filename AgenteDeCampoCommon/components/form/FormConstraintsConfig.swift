//
//  FormConstraintsConfig.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 11/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import CoreGraphics

public struct FormConstraintsConfig {
    public let left: CGFloat
    public let top: CGFloat
    public let right: CGFloat
    public let bottom: CGFloat
    public var offset: CGFloat = 80

    public init(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }

    public init() {
        self.init(left: 1, top: 1, right: 1, bottom: 1)
    }
}
