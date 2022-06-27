//
//  MonthStrategy.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 01/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct MonthStrategy: FormatedDateStrategy {

    var next: FormatedDateStrategy?

    func getHumanDate(from date: Date, to other: Date) -> String {
        let components = Calendar.init(identifier: .gregorian)
            .dateComponents([.minute, .hour, .day, .month, .year],
                            from: date, to: other)
        let month = components.month!
        let year = components.year!

        if year > 0 || month == 0 {
            return next?.getHumanDate(from: date, to: other) ?? "---"
        }
        let monthStr = month > 1 ? "meses" : "mês"
        return "Há \(month) \(monthStr)"

    }
}
