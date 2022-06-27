//
//  Driver.swift
//  Driver
//
//  Created by Samir Chaves on 14/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation

public struct Driver: Codable {
    public let general: General
    public let individual: Individual
    public let cnhRequirements: [String]
    public let pidRequirements: [String]
    public let occurrences: [Occurrence]
    public let courses: [Course]
}

public struct General: Codable {
    public let renach: String
    public let rne: String
    public let pgu: String
    public let firstCnh: FirstCnh
    public let currentCnh: CNH
    public let lastCnhStatus: String
    public let foreignCnh: ForeignCNH?
    public let pid: PID
    public let medicRestrictions: String
    public let observations: String
}

public struct Individual: Codable {
    public let name: String
    public let mother: String
    public let father: String
    public let birth: Birth
    public let sex: String
    public let cpf: String
    public let nationality: String
    public let address: Address?
    public let document: Document
}

public struct Occurrence: Codable {
    public let uf: String
    public let start: String
    public let end: String
    public let document: String
    public let description: String
    public let reason: String
    public let decision: String
    public let liberation: String?
    public let deadline: String
    public let totalDeadline: String
}

public struct Course: Codable {
    public let type: String
    public let description: String?
    public let uf: String?
    public let date: String?
}

public struct Document: Codable {
    public let uf: String
    public let number: String
    public let description: String
    public let organization: String
}

public struct Address: Codable {
    public let place: String
    public let number: String
    public let complement: String
    public let district: String
    public let city: String
    public let cep: String
    public let uf: String
}

public struct PID: Codable {
    public let number: String
    public let status: String
    public let uf: String
    public let expirationDate: String?
}

public struct CNH: Codable {
    public let number: String
    public let registrationNumber: String
    public let status: String
    public let uf: String
    public let transferedUf: String?
    public let issueDate: String?
    public let category: Category
    public let expirationDate: String
    public let suspendedUntil: String?
    public let suspendedAt: String?
    public let cnhWarning: CNHWarning?

    public func getExpirationDate() -> Date? {
        expirationDate.toDate(format: "yyyy-MM-dd'T'HH:mm:ssXXXXX")
    }

    public func getSuspensionStartDate() -> Date? {
        suspendedAt?.toDate(format: "yyyy-MM-dd'T'HH:mm:ssXXXXX")
    }

    public func getSuspensionEndDate() -> Date? {
        suspendedUntil?.toDate(format: "yyyy-MM-dd'T'HH:mm:ssXXXXX")
    }

    public func getTimeToExpire() -> DateComponents? {
        let timeToExpire = getExpirationDate()?.difference(to: Date(), [.month, .year])
        if let month = timeToExpire?.month, let year = timeToExpire?.year, month < 0 || year < 0 {
            return nil
        }

        return timeToExpire
    }

    public func getTimeHasSuspended() -> DateComponents? {
        let timeHasSuspended = getSuspensionStartDate()?.difference(to: Date(), [.month, .year])

        if let month = timeHasSuspended?.month, let year = timeHasSuspended?.year, month < 0 || year < 0 {
            return nil
        }

        return timeHasSuspended
    }

    public func isOverdue() -> Bool {
        let timeToExpire = getTimeToExpire()
        return status == "VENCIDA" && timeToExpire != nil
    }

    public func isSuspended() -> Bool {
        let timeHasSuspended = getTimeHasSuspended()
        return status == "SUSPENSA" && timeHasSuspended != nil
    }

    public func hasAlerts() -> Bool {
        isOverdue() || isSuspended()
    }
}

public struct CNHWarning: Codable {
    public let message: String
    public let description: String
}

public struct ForeignCNH: Codable {
    public let id: String?
    public let date: String?
    public let country: String?
}

public struct Category: Codable {
    public let current: String
    public let demoted: String
    public let authorized: String
}

public struct Birth: Codable {
    public let date: String
    public let place: String
    public let description: String
}

public struct FirstCnh: Codable {
    public let uf: String
    public let date: String
}
