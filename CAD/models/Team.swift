//
//  Team.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct Team: Codable {
    public let expectedEndDateTime: String?
    public let expectedStartDateTime: String?
    public let equipments: [Equipment]
    public let teamPeople: [TeamPerson]
    public let timeZone: String
    public let endReason: String?
    public let mixed: Bool
    public let name: String
    public let operatingRegions: [OperatingRegion]
    public let situation: String
    public let phone: String?
    public let id: UUID

    private func removeMillisecondes(_ dateStr: String?) -> String? {
        return dateStr?.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
    }

    var startDateStr: String {
        guard let isoDateTime = removeMillisecondes(expectedStartDateTime) else { return "" }
        guard let date = readerDateFormatter.date(from: isoDateTime) else { return "" }
        return writerDateFormatter.string(from: date)
    }

    var startDate: Date? {
        guard let isoDateTime = removeMillisecondes(expectedStartDateTime) else { return nil }
        return readerDateFormatter.date(from: isoDateTime)
    }

    var endDate: Date? {
        guard let isoDateTime = expectedEndDateTime else { return nil }
        return readerDateFormatter.date(from: isoDateTime)
    }

    var endDateStr: String {
        guard let date = endDate else { return "" }
        return writerDateFormatter.string(from: date)
    }

    var startHour: String {
        extractHourFrom(date: startDate)
    }

    var endHour: String {
        extractHourFrom(date: endDate)
    }

    private func extractHourFrom(date optionalDate: Date?) -> String {
        guard let date = optionalDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    var duration: String {
        guard let start = startDate,
            let end = endDate else { return "" }
        let interval = DateInterval(start: start, end: end)
        let duration = interval.duration
        return duration.toHour
    }

    var readerDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }

    var writerDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }

    func hasVehicles() -> Bool {
        getVehicles().count > 0
    }

    func getVehicles() -> [Equipment] {
        equipments.filter { $0.kmAllowed }
    }

    func toNonCritical() -> NonCriticalTeam {
        NonCriticalTeam(
            expectedEndDateTime: expectedEndDateTime,
            expectedStartDateTime: expectedStartDateTime,
            equipments: equipments,
            teamPeople: teamPeople.map { $0.toSimple() },
            timeZone: timeZone,
            name: name,
            operatingRegions: operatingRegions,
            situation: situation,
            id: id
        )
    }

    func toSimpleTeam() -> SimpleTeam {
        SimpleTeam(name: name, id: id)
    }
}

public struct TeamBasic: Codable {
    public let name: String
    public let id: UUID
}

public struct NonCriticalTeam: Codable, Hashable {
    public let expectedEndDateTime: String?
    public let expectedStartDateTime: String?
    public let equipments: [Equipment]
    public let teamPeople: [SimpleTeamPerson]
    public let timeZone: String
    public let name: String
    public let operatingRegions: [OperatingRegion]
    public let situation: String
    public let id: UUID

    private func removeMillisecondes(_ dateStr: String?) -> String? {
        return dateStr?.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: NonCriticalTeam, rhs: NonCriticalTeam) -> Bool {
        return lhs.id == rhs.id
    }

    var startDateStr: String {
        guard let isoDateTime = removeMillisecondes(expectedStartDateTime) else { return "" }
        guard let date = readerDateFormatter.date(from: isoDateTime) else { return "" }
        return writerDateFormatter.string(from: date)
    }

    var startDate: Date? {
        guard let isoDateTime = removeMillisecondes(expectedStartDateTime) else { return nil }
        return readerDateFormatter.date(from: isoDateTime)
    }

    var endDate: Date? {
        guard let isoDateTime = expectedEndDateTime else { return nil }
        return readerDateFormatter.date(from: isoDateTime)
    }

    var endDateStr: String {
        guard let date = endDate else { return "" }
        return writerDateFormatter.string(from: date)
    }

    var startHour: String {
        extractHourFrom(date: startDate)
    }

    var endHour: String {
        extractHourFrom(date: endDate)
    }

    private func extractHourFrom(date optionalDate: Date?) -> String {
        guard let date = optionalDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    var duration: String {
        guard let start = startDate,
            let end = endDate else { return "" }
        let interval = DateInterval(start: start, end: end)
        let duration = interval.duration
        return duration.toHour
    }

    var readerDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }

    var writerDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }
}

extension TimeInterval {

    var toHour: String {
        let ti = NSInteger(self)
        let minutes = (ti / 60) % 60
        let hour = ti / 3600
        return String(format: "%0.2d:%0.2d Hr", hour, minutes).pluralizeIf(hour > 1 )
    }
}

extension String {

    func pluralizeIf(_ condition: Bool, adding: String = "s" ) -> String {
        if condition {
            return self + adding
        }
        return self
    }
}
