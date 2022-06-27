//
//  Date+AgenteCampo.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 11/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation

public extension Date {
    func format(to format: String, timeZone: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "pt_BR")
        if let timeZoneStr = timeZone,
           let timeZone = TimeZone(abbreviation: timeZoneStr) {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: self)
    }

    func convertToUTC() -> Date? {
        let timezoneOffset = TimeZone.current.secondsFromGMT(for: self)
        return Date(timeInterval: -TimeInterval(timezoneOffset), since: self)
    }

    func fromUTCTo(_ timeZone: String = "UTC") -> Date {
        var sourceOffset = TimeInterval(TimeZone(abbreviation: "UTC")!.secondsFromGMT(for: self))
        var fixedTimeZone: TimeZone!
        switch timeZone {
        case "ACT":
            fixedTimeZone = TimeZone(identifier: "America/Rio_Branco")!
        case "AMT":
            fixedTimeZone = TimeZone(identifier: "America/Manaus")!
        case "AMST":
            fixedTimeZone = TimeZone(identifier: "America/Manaus")!
            sourceOffset -= fixedTimeZone.daylightSavingTimeOffset(for: self)
        case "BRT":
            fixedTimeZone = TimeZone(identifier: "America/Sao_Paulo")!
        case "BRST":
            fixedTimeZone = TimeZone(identifier: "America/Sao_Paulo")!
            sourceOffset -= fixedTimeZone.daylightSavingTimeOffset(for: self)
        case "FNT":
            fixedTimeZone = TimeZone(identifier: "America/Noronha")!
        default:
            fixedTimeZone = TimeZone(abbreviation: "UTC")!
        }
        let destinationOffset = TimeInterval(fixedTimeZone.secondsFromGMT(for: self))
        let timeInterval = destinationOffset - sourceOffset
        return Date(timeInterval: timeInterval, since: self)
    }

    func difference(to date: Date, _ components: Set<Calendar.Component>) -> DateComponents {
        Calendar.current.dateComponents(components, from: self, to: date)
    }

    func toGreet(lowercased: Bool = true) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        var greet = "Boa noite"
        if hour > 2 && hour < 12 {
            greet = "Bom dia"
        } else if hour >= 12 && hour < 18 {
            greet = "Boa tarde"
        }

        if lowercased {
            return greet.lowercased()
        }

        return greet
    }
}

private typealias DateComponentText = (singular: String, plural: String, short: String)

public extension DateComponents {
    func getComponentText(_ component: Int, for componentType: Calendar.Component, shortText: Bool) -> String {
        let componentsTexts: [Calendar.Component: DateComponentText] = [
            .year: (singular: "ano", plural: "anos", short: "a"),
            .month: (singular: "mês", plural: "meses", short: "m"),
            .day: (singular: "dia", plural: "dias", short: "d"),
            .hour: (singular: "hora", plural: "horas", short: "h"),
            .minute: (singular: "minuto", plural: "minutos", short: "min")
        ]
        let compontextText = componentsTexts[componentType]!
        var text = compontextText.singular
        if shortText {
            text = compontextText.short
        } else if component > 1 {
            text = compontextText.plural
        }
        return text
    }

    func humanize(shortText: Bool = true, rounded: Bool = false) -> String {

        var textPieces = [String]()
        if let year = self.year, year > 0 {
            let text = getComponentText(year, for: .year, shortText: shortText)
            textPieces.append("\(year) \(text)")
            if rounded {
                return "Há \(year) \(text)"
            }
        }
        if let month = self.month, month > 0 {
            let text = getComponentText(month, for: .month, shortText: shortText)
            textPieces.append("\(month) \(text)")
            if rounded {
                return "Há \(month) \(text)"
            }
        }
        if let day = self.day, day > 0 {
            let text = getComponentText(day, for: .day, shortText: shortText)
            textPieces.append("\(day) \(text)")
            if rounded {
                return "Há \(day) \(text)"
            }
        }
        if let hour = self.hour, hour > 0 {
            let text = getComponentText(hour, for: .hour, shortText: shortText)
            textPieces.append("\(hour) \(text)")
            if rounded {
                return "Há \(hour) \(text)"
            }
        }
        if let minute = self.minute, minute > 0 {
            let text = getComponentText(minute, for: .minute, shortText: shortText)
            textPieces.append("\(minute) \(text)")
            if rounded {
                return "Há \(minute) \(text)"
            }
        }
        if textPieces.isEmpty {
            return "Agora"
        }

        if textPieces.count == 1 {
            return "Há " + textPieces[0]
        }

        return "Há " + textPieces[0 ..< textPieces.endIndex - 1].joined(separator: ", ") + " e " + textPieces[textPieces.endIndex - 1]
    }

    func simpleHumanize(date: Date, shortText: Bool = false) -> String {
        if let day = self.day, day > 0 {
            return date.format(to: "dd/MM/yyyy HH:mm:ss")
        }

        if let hour = self.hour, hour > 0 {
            let text = getComponentText(hour, for: .hour, shortText: shortText)
            return "Há \(hour) \(text)"
        }

        if let minute = self.minute, minute > 0 {
            let text = getComponentText(minute, for: .minute, shortText: shortText)
            return "Há \(minute) \(text)"
        }

        return "Agora"
    }
}
