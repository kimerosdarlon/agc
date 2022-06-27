//
//  CGFLoat+Agente.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    func valueBetween(value1: CGFloat, value2: CGFloat) -> CGFloat {
        if self > value1 && self < value2 {
            return self
        } else if self < value1 {
            return value1
        }
        return value2
    }
}
