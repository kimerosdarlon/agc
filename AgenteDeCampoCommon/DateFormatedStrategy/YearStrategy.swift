//
//  YearStrategy.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 01/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct YearStrategy: FormatedDateStrategy {

    var next: FormatedDateStrategy?

    func getHumanDate(from date: Date, to other: Date) -> String {
        let components = Calendar.init(identifier: .gregorian)
            .dateComponents([.minute, .hour, .day, .month, .year],
                            from: date, to: other)
        let year = components.year!
        let month = components.month!

        if year == 0 {
            return next?.getHumanDate(from: date, to: other) ?? "---"
        }
        let yearStr = year > 1 ? "anos" : "ano"

        if month > 0 {
            return "Há mais de \(year) \(yearStr)"
        }

        return "Há \(year) \(yearStr)"

    }
}
