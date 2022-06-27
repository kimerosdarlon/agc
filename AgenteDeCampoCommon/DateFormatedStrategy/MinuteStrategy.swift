//
//  MinuteStrategy.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct MinuteStrategy: FormatedDateStrategy {
    var next: FormatedDateStrategy?

    func getHumanDate(from date: Date, to other: Date) -> String {
        let components = Calendar.init(identifier: .gregorian)
            .dateComponents([.minute, .hour, .day, .month, .year],
                            from: date, to: other)
        let minute = components.minute!
        let hour = components.hour!
        let day = components.day!
        let month = components.month!
        let year = components.year!

        if hour > 0 || day > 0 || month > 0 || year > 0 {
            return next?.getHumanDate(from: date, to: other) ?? "---"
        }
        let minuteText = minute > 1 ? "minutos" : "minuto"
        return "Há \(minute) \(minuteText)"
    }
}
