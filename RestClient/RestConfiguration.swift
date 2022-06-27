//
//  RestConfiguration.swift
//  RestClient
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public protocol RestConfiguration {
    var debug: Bool { get }
    var host: String { get }
}
