//
//  DateStratagy.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct DateStratagy: FormatedDateStrategy {
    var next: FormatedDateStrategy?

    func getHumanDate(from date: Date, to other: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}
