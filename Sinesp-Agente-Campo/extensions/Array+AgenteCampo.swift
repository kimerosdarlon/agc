//
//  Array+AgenteCampo.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 01/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {

    static func - (listA: [Element], listB: [Element]) -> [Element] {
        var acumulator = [Element]()
        for element in listA {
            if !listB.contains(where: {$0 == element}) {
                acumulator.append(element)
            }
        }
        return acumulator
    }
}
