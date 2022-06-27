//
//  Destination.swift
//  Logger
//
//  Created by Ramires Moreira on 13/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public protocol Destination {
    var level: LoggerLevel { get set }
    func send(message: String, level: LoggerLevel)
}
