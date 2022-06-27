//
//  DayStrategy.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct DayStrategy: FormatedDateStrategy {
    var next: FormatedDateStrategy?

    func getHumanDate(from date: Date, to other: Date) -> String {
        let components = Calendar.init(identifier: .gregorian)
            .dateComponents([.minute, .hour, .day, .month, .year],
                            from: date, to: other)
        let day = components.day!
        let month = components.month!
        let year = components.year!

        if month > 0 || year > 0 || day >= 7 {
            return next?.getHumanDate(from: date, to: other) ?? "---"
        }
        let dayText = day > 1 ? "dias" : "dia"
        return "Há \(day) \(dayText)"
    }
}
