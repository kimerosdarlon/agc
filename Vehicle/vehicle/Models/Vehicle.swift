//
//  Vehicle.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 28/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import MapKit
import AgenteDeCampoCommon

public struct Vehicle: Codable {
    public var plate: String?
    public var renavam: String?
    public var model: String?
    public var color: String?
    public var chassis: String?
    public var markupChassis: Bool?
    public var bodyworkType: String?
    public var fuelType: String?
    public var specie: String?
    public var group: String?
    public var type: String?
    public var mountingType: String?
    public var characteristicsLastUpdate: String?
    public var manufactureYear: Int?
    public var modelYear: Int?
    var alerts: [VehicleAlert]?
    public var restrictions: [String]?
    public var hasAlert: Bool
    public var alertSystemOutOfService: Bool
    var owner: Owner?
    var possessor: Owner?
    var renter: Owner?
    public var city: String?
    var mechanics: Mechanics?
    var capacity: Capacity?
    var licensePlate: LicensePlate?
    var billing: Billing?
    var identifiers: Identifiers?
    var vehicleImport: VehicleImport?
    public var conversionAlert: String?
    public var completed: Bool?

    func getYears() -> String {
        return "\(manufactureYear ?? 0)/\(modelYear ?? 0)"
    }

    var remarcado: String {
        return ( markupChassis ?? false) ? "Sim" : "Não"
    }

    var chargeTon: String {
        if let charge = capacity?.chargeKg, charge > 0 {
            return "\(Double(charge)/1000)"
        }
        return "---"
    }

    var passengers: String {
        return "\(capacity?.passengers ?? 0)"
    }

    var totalGrossWeight: String {
        if let capacity = capacity?.totalGrossWeight, capacity > 0 {
            return "\(capacity/1000)"
        }
        return "---"
    }

    var restriction: String? {
        let formatedString = self.restrictions?.joined(separator: "\n -") ?? ""
        return formatedString.isEmpty ? nil : "- " + formatedString
    }

    mutating func configure(usin data: VehicleResult) {
        owner = data.owner
        modelYear = data.years.model
        manufactureYear = data.years.manufacture
        city = data.licensePlate.city
        billing = data.billing
        alerts = data.alerts
        capacity = data.capacity
        licensePlate = data.licensePlate
        mechanics = data.mechanics
        possessor = data.possessor
        renter = data.renter
        restrictions = data.restrictions
        vehicleImport = data.`import`
        conversionAlert = data.conversionAlert
        identifiers = data.identifiers
        hasAlert = data.hasAlert
        alertSystemOutOfService = data.alertSystemOutOfService
        self.completed = data.completed
        self.modelYear = data.years.model
        self.manufactureYear = data.years.manufacture
    }

    var hasAnyOwner: Bool {
        return owner != nil || possessor != nil || renter != nil
    }
}

struct VehicleGeneral: Codable {
    let plate: String
    let renavam: String
    let model: String
    let color: String
    let chassis: String
    let markupChassis: Bool
    let bodyworkType: String
    let fuelType: String
    let specie: String
    let group: String
    let type: String
    let mountingType: String
    let characteristicsLastUpdate: String
}

public struct VehicleResult: Codable {
    var general: VehicleGeneral
    let years: VehicleYears
    let licensePlate: LicensePlate
    let possessor: Owner?
    let owner: Owner?
    let renter: Owner?
    let restrictions: [String]?
    let mechanics: Mechanics?
    let capacity: Capacity?
    let `import`: VehicleImport?
    let billing: Billing?
    let completed: Bool
    let alerts: [VehicleAlert]
    let identifiers: Identifiers?
    let conversionAlert: String?
    let hasAlert: Bool
    let alertSystemOutOfService: Bool

    public func toVehicle() -> Vehicle {
        Vehicle(
            plate: general.plate,
            renavam: general.renavam,
            model: general.model,
            color: general.color,
            chassis: general.chassis,
            markupChassis: general.markupChassis,
            bodyworkType: general.bodyworkType,
            fuelType: general.fuelType,
            specie: general.specie,
            group: general.group,
            type: general.type,
            mountingType: general.mountingType,
            characteristicsLastUpdate: general.characteristicsLastUpdate,
            manufactureYear: years.manufacture,
            modelYear: years.model,
            alerts: alerts,
            restrictions: restrictions,
            hasAlert: hasAlert,
            alertSystemOutOfService: alertSystemOutOfService,
            owner: owner,
            possessor: possessor,
            renter: renter,
            city: licensePlate.city,
            mechanics: mechanics,
            capacity: capacity,
            licensePlate: licensePlate,
            billing: billing,
            identifiers: identifiers,
            vehicleImport: `import`,
            conversionAlert: conversionAlert,
            completed: completed
        )
    }
}

struct Billing: Codable {
    var document: Document
    var state: String
}

struct Owner: Codable {
    let name: String
    let address: String?
    var birthdayDate: String?
    var document: Document?
}

struct Document: Codable {
    let type: String?
    let number: String
}

struct Capacity: Codable {
    let chargeKg: Int
    let passengers: Int
    let totalGrossWeight: Int
}

struct VehicleYears: Codable {
    let manufacture: Int
    let model: Int
}

struct LicensePlate: Codable {
    let city: String
    let state: String?
    let date: String

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let date = formatter.date(from: self.date) ?? Date()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

struct Mechanics: Codable {
    let axleQuantity: Int?
    let engineCapacity: Int?
    let potencyHp: Int?
    let tractionKg: Int?
}

struct VehicleImport: Codable {
    let importerId: String
    let declarationId: String
    let date: String

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let date = formatter.date(from: self.date) ?? Date()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

struct VehicleAlert: Codable {
    let type: String
    let occurrenceDate: String
    let occurrenceBulletin: OccurrenceBulletin?
    let contact: Contact?

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: occurrenceDate) else {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let date = formatter.date(from: occurrenceDate) else { return "Data não informada" }
            formatter.dateFormat = "dd/MM/yyyy 'ás' HH:mm"
            return formatter.string(from: date)
        }
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

struct Contact: Codable {
    let name: String
    let cellphone: String

    var formattedCellFone: String {
        return cellphone.apply(pattern: "(##) #########", replacmentCharacter: "#")
    }
}

struct OccurrenceBulletin: Codable {
    let number: String
    let state: String
    let city: String
    let year: Int?
    let historic: String
    let policeStation: String
    let system: String
}

struct Identifiers: Codable {
    let gearbox: String // caixa de câmbio
    let bodywork: String // carroceria
    let motor: String
    let auxiliaryShaft: String // eixo auxiliar
    let rearAxle: String // eixo traseiro
}

class VehicleLocation: NSObject, Codable, MKAnnotation {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    let moment: String
    let location: Location
    let local: String

    var title: String? {
        return local
    }

    var date: Date {
        let formater = DateFormatter()
        formater.timeZone = TimeZone.init(identifier: "UTC")
        formater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formater.date(from: moment) ?? Date()
    }

    /// Este método é usado para classificar a posição de uma data em relação ao array passado como argumento.
    /// o array deve possuir um data que seja igual ao `date` do `VehicleLocation`. Em suma este método serve
    /// para que seja possível definir qual imagen do sensor deve ser mostrada, entre as mais claras e mais escuras.
    /// - Parameters:
    ///   - dates: um `[Date]` que tenha pelo menos uma data que seja a mesma do `VehicleLocation` em questão.
    ///   - order: `ComparisonResult` que determine se deseja ordenar em ordem crescente ou decrescente
    /// - Throws: Lança exceção em caso de um array vazio ou no caso do array não contenha a data do `VehicleLocation`
    /// - Returns: um número inteiro que corresponde a posição ( clasificação ), da data no array passado.
    func getRankingIn(dates: [Date], order: ComparisonResult = .orderedAscending) throws -> Int {
        if dates.isEmpty {
            throw NSError(domain: "The array can't be empty", code: 1, userInfo: nil)
        }
        let sorted = dates.sorted(by: { $0.compare($1) == order })
        guard let index = sorted.firstIndex(of: date) else {
            throw NSError(domain: "The date is not present in array", code: 2, userInfo: nil)
        }
        return index
    }
}
