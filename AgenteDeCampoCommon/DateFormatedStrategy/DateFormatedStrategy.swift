//
//  DateFormatedStrategy.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public protocol FormatedDateStrategy {
    var next: FormatedDateStrategy? {get set}
    func getHumanDate(from date: Date, to other: Date) -> String
}
