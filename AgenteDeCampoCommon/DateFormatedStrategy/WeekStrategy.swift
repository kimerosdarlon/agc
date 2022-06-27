//
//  WeekStrategy.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 01/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct WeekStrategy: FormatedDateStrategy {
    var next: FormatedDateStrategy?

    func getHumanDate(from date: Date, to other: Date) -> String {
        let components = Calendar.init(identifier: .gregorian)
            .dateComponents([.minute, .hour, .day, .month, .year, .weekOfMonth],
                            from: date, to: other)
        let month = components.month!
        let year = components.year!
        let week = components.weekOfMonth!

        if month > 0 || year > 0 {
            return next?.getHumanDate(from: date, to: other) ?? "---"
        }
        let weekText = week > 1 ? "semanas" : "semana"
        return "Há \(week) \(weekText)"
    }
}
