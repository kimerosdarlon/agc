//
//  DispachMain+Extension.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 21/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public func garanteeMainThread( _ work: @escaping () -> Void ) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async(execute: work)
    }
}
