//
//  Models.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 22/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

struct BulletinItem: Codable {
    let id: Int
    let codeState: String
    let codeNational: String
    let state: String?
    let city: String?
    let registryDateTime: String
    let registryPoliceStation: String
    let responsiblePoliceStation: String
    let peopleInvolved: [PersonInvolved]
    let objects: BulletinObject

    var formatedRegistryDateTime: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        var date: Date?
        if let firstDate = dateFormatter.date(from: registryDateTime) {
            date = firstDate
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            date = dateFormatter.date(from: registryDateTime)
        }
        if let date = date {
            dateFormatter.locale = Locale(identifier: "pt_BR")
            dateFormatter.dateFormat = "dd/MM/yyyy 'ás' HH:mm"
            return dateFormatter.string(from: date)
        }
        return nil
    }
}

enum BulletinObjectType: String, Codable {
    case vehicle
    case weapon
    case cellphone
    case other
    case people

    var image: UIImage {
        switch self {
        case .cellphone:
            return UIImage(named: "smartphone")!
        case .people:
            return UIImage(systemName: "person.3.fill")!
        case .other:
            return UIImage(systemName: "ellipsis.circle.fill")!
        case .vehicle:
            return UIImage(systemName: "car.fill")!
        case .weapon:
            return UIImage(named: "gun")!
        }
    }
}

struct VehicleBulletim: Codable {
//    let bulletinId: Int
    let plate: String?
    let chassis: String?
    let brand: String?
    let model: String?
    let color: String?
    let owner: Owner?
    let qualifications: [String]
}

struct Weapons: Codable {
//    let bulletinId: Int
    let brand: String?
    let model: String?
    let caliber: Int?
    let identification: String?
    let sinarmId: String?
    let usage: String?
    let manufactureOrigin: String?
    let owner: Owner?
    let qualifications: [String]

    var caliberStr: String? {
        if let caliber = caliber {
            return "\(caliber)"
        }
        return nil
    }
}

struct Cellphones: Codable {
//    let bulletinId: Int
    let imeis: [String]
    let brand: String?
    let model: String?
    let serialNumber: String?
    let qualifications: [String]
    let owner: Owner?

    var imei: String? {
        return imeiAt(position: 0)
    }

    var imei2: String? {
        imeiAt(position: 1)
    }

    var imei3: String? {
        imeiAt(position: 2)
    }

    var imei4: String? {
        imeiAt(position: 3)
    }

    private func imeiAt(position: Int ) -> String? {
        if imeis.count - 1 >= position {
            return imeis[position]
        }
        return nil
    }
}

struct BulletinGenericObject: Codable {
//    let objectId: Int
    let description: String?
    let subgroup: String
    let qualifications: [String]
//    let involvements: [ObjectInvolvement]
}

struct ObjectInvolvement: Codable {
    let personId: Int
    let types: [String]
}

struct Owner: Codable {
    let type: String
    let cpf: String?
    let cnpj: String?
    let name: String?
    let nickname: String?
    let socialName: String?
    let companyName: String?

    enum CodingKeys: String, CodingKey {
        case cpf
        case type = "_type"
        case name
        case nickname
        case socialName
        case cnpj
        case companyName
    }
}

struct BulletinObject: Codable {
    let vehicles: [VehicleBulletim]
    let weapons: [Weapons]
    let others: [BulletinGenericObject]
    let cellphones: [Cellphones]
    let documents: [Documents]?
    let drugs: [Drugs]?
}

struct Documents: Codable {
    let type: String
    let number: String?
    let qualifications: [String]
}

struct Drugs: Codable {
//    let id: Int
    let description: String?
    let appearance: String?
    let packing: DrugDomainType? // embalagem
    let location: DrugDomainType? // localização (hospital, delegacia)
    let natures: [String]
    let involvements: [ObjectInvolvement]
    let qualifications: [String]
}

struct DrugDomainType: Codable {
    let name: String?
    let observation: String?
}

struct PersonInvolved: Codable {
    let bulletinId: Int
    let id: Int
    let name: String?
    let socialName: String?
    let companyName: String?
    let nickname: String?
    let birthDate: String?
    let involvements: [Involvement]

    var ageStr: String {
        if let birthDateStr = birthDate {
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let birthDate = dateFormatter.date(from: birthDateStr) {
                let calendar = Calendar.init(identifier: .gregorian)
                let years = calendar.dateComponents([.year], from: birthDate, to: today).year ?? 0
                return " | \(years) Anos"
            }
        }
        return ""
    }
}

struct Involvement: Codable {
    let involvements: [String]
    let nature: String
}

struct BulletinDetails: Codable {
    let id: Int // ok
    let codeState: String // ok
    let codeNational: String // ok
    let registryDateTime: String // ok
    let registryPoliceStation: String? // ok
    let responsiblePoliceStation: String? // ok
    let story: String? // ok
    let startDateTime: String? // ok
    let endDateTime: String? // ok
    let isTimeApproximated: Bool // ok
    let isDateApproximated: Bool // ok
    let address: Address // ok
    let natures: [String] // ok
    let peopleInvolved: [PersonInvolvedDetail]
    let objects: BulletinObject
}

enum ServiceType: String, Codable {
    case physical
    case legal
    case national
    case state
    case vehicle = "objects/vehicles"
    case weapons = "objects/weapons"
    case cellphones = "objects/cellphones"
}

struct PersonInvolvedDetail: Codable {
    let personId: Int
    let cpf: String?
    let name: String?
    let socialName: String?
    let nickname: String?
    let birthDate: String?
    let motherName: String?
    let fatherName: String?
    let sexualOrientation: String?
    let genderIdentity: String?
    let nationality: String?
    let address: Address?
    let cnpj: String?
    let companyName: String?
    let businessLine: String?
    let representative: String?
    let isState: Bool?
    let type: ServiceType
    let involvements: [Involvement]
    let documents: [Document]
    var isPhysical: Bool {
        return type == .physical
    }

    var isLegal: Bool {
        return type == .legal
    }

    enum CodingKeys: String, CodingKey {
        case personId
        case cpf
        case name
        case socialName
        case nickname
        case birthDate
        case motherName
        case fatherName
        case sexualOrientation
        case genderIdentity
        case nationality
        case address
        case cnpj
        case companyName
        case businessLine
        case representative
        case isState
        case type = "_type"
        case involvements
        case documents
    }
}

struct Document: Codable {
    let type: String
    let number: String?
    let qualifications: [String]?
}

struct Address: Codable {
    let street: String?
    let number: String?
    let complement: String?
    let district: String?
    let city: String?
    let state: String?
    let country: String?
    let zipCode: String?
    let reference: String?
    let location: Location?
    let local: String?
}
