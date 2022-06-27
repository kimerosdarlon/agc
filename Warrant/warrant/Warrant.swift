//
//  Mandado.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct WarrantType: Codable {
    let id: Int
    let name: String
}

struct Warrant: Codable {
    let id: Int
    let personName: String
    let situation: String
    let expeditionDate: String
    let type: WarrantType
}

struct WarrantDetails: Codable {
    let id: Int
    let personal: Personal
    let piece: Piece
    let expedition: Expedition
    let sentence: Sentence
    let prison: Prison
}

struct Personal: Codable {
    let name: [String]
    let nickname: [String]
    let motherName: String?
    let fatherName: String?
    let birthDate: String?
    let nationality: String?
    let placeOfBirth: String?
    let gender: String

    var hasBirthDate: Bool {
        guard let birhtDay = birthDate, !birhtDay.isEmpty else {
            return false
        }
        return true
    }

    var age: String {
        if !hasBirthDate { return "" }
        guard let birthDate = birthDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: birthDate) else { return "" }
        let components = Calendar.init(identifier: .gregorian).dateComponents([.year], from: date, to: Date())
        guard let year = components.year else { return "" }
        return "\(year) anos"
    }

    var birthDateFormatted: String {
        guard let birthDate = birthDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: birthDate) else { return "" }
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

struct Piece: Codable {
    let type: WarrantType
    let situation: String
    let pieceNumber: String
    let processNumber: String
    let validityDate: String

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let date = formatter.date(from: self.validityDate) ?? Date()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

struct Expedition: Codable {
    let reason: String?
    let date: String
    let licenseReason: String?
    let organ: Organ

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let date = formatter.date(from: self.date) ?? Date()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

struct Organ: Codable {
    let name: String
    let city: String
    let state: String
}

struct Sentence: Codable {
    let magistrate: String?
    let synthesis: String?
}

struct Prison: Codable {
    let time: Time
    let regime: String?
    let type: String?

    var prisionTime: String {
        let years = time.years ?? 0
        let months = time.months ?? 0
        let days = time.days ?? 0
        let yearsStr = years > 1 ? "Anos" : "Ano"
        let monthsStr = months > 1 ? "Meses" : "Mês"
        let daysStr = days > 1 ? "Dias" : "Dia"
        return "\(years) \(yearsStr) - \(months) \(monthsStr) - \(days) \(daysStr)"
    }
}

struct Time: Codable {
    let years: Int?
    let months: Int?
    let days: Int?
}
