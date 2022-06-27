//
//  CDRecentes+Extension.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 10/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

extension CDRecents {

    @objc
    public var computedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone.current
        formatter.doesRelativeDateFormatting = true
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .long
        guard let date = date else { return ""}
        return formatter.string(from: date)
    }
}
