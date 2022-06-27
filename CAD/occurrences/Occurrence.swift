//
//  Occurrence.swift
//  CAD
//
//  Created by Samir Chaves on 08/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import MapKit

public struct OccurrenceDetails: Codable {
    public let occurrenceId: UUID
    public let generalInfo: OccurrenceGeneralInfo
    public let dispatches: [Dispatch]
    public let captureRegion: CaptureRegion
    public let history: [History]
    public let receiver: Operator
    public let dispatcherOperator: Operator?
    public let activities: String?
    public let narrative: String?
    public let natures: [Nature]
    public let operatingRegion: OperatingRegion
    public let drugs: [OccurrenceNatures<Drug>]
    public let involved: [OccurrenceNatures<Involved>]
    public let weapons: [OccurrenceNatures<Weapon>]
    public let address: Location
    public let linked: [ComplementaryOccurrence]
    public let complementary: [ComplementaryOccurrence]
    public let vehicles: [OccurrenceNatures<Vehicle>]
    public let finalization: History?
    public let firstTeamDispatched: Dispatch?

    public func toSimple(allocatedTeams: [SimpleTeam] = []) -> SimpleOccurrence {
        return SimpleOccurrence(
            generalAlert: generalInfo.generalAlert,
            priority: generalInfo.priority,
            situation: generalInfo.situation,
            protocol: generalInfo.protocol,
            serviceRegisteredAt: generalInfo.serviceRegisteredAt,
            address: address,
            allocatedTeams: allocatedTeams,
            natures: natures.map { $0.toBasic() },
            operator: dispatcherOperator,
            operatingRegion: operatingRegion,
            id: occurrenceId,
            complementaryNumber: complementary.count,
            mainOccurrenceId: generalInfo.mainOccurrenceId
        )
    }

    func toAddressUpdate(teamId: UUID, version: Int? = nil) -> AddressUpdate {
        AddressUpdate(
            address: LocationUpdate(
                district: address.district,
                ibgeCityCode: address.ibgeCityCode,
                complement: address.complement,
                coordinates: address.coordinates,
                km: address.km,
                street: address.street,
                city: address.city,
                number: address.number,
                highwayLane: address.highwayLane,
                referencePoint: address.referencePoint,
                highway: address.highway,
                roadDirection: address.roadDirection,
                placeType: address.placeType,
                roadType: address.roadType,
                stretch: address.stretch,
                state: address.state,
                version: version ?? address.version
            ),
            teamId: teamId
        )
    }

    public func toPushNotification(dispatch: Dispatch) -> OccurrencePushNotification {
        return OccurrencePushNotification(dispatch: dispatch, occurrenceDetails: self)
    }
}

public struct OccurrenceNatures<T: Codable>: Codable {
    public let objects: [NaturesVersion]
    public let component: T
}

public struct NaturesVersion: Codable, Hashable {
    public let id: UUID
    public let version: Int
    public let nature: String
    public let situation: String?
}

public struct SimpleOccurrence: Codable {
    public let generalAlert: Bool
    public let priority: OccurrencePriority
    public let situation: OccurrenceSituation
    public let `protocol`: String
    public let serviceRegisteredAt: DateTimeWithTimeZone
    public let address: Location
    public let allocatedTeams: [SimpleTeam]
    public let natures: [BasicNature]
    public let `operator`: Operator?
    public let operatingRegion: OperatingRegion
    public let id: UUID
    public let complementaryNumber: Int
    public let mainOccurrenceId: UUID?
}

public enum OccurrencePriority: String, Codable, Hashable, Comparable {
    case redAlert = "Alerta Vermelho"
    case high = "Alta"
    case medium = "Média"
    case low = "Baixa"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringForRawValues = try container.decode(String.self)

        switch stringForRawValues {
        case "ALERTA_VERMELHO":
            self = .redAlert
        case "ALTA":
            self = .high
        case "MEDIA":
            self = .medium
        case "BAIXA":
            self = .low
        default:
            throw AnswerError.missingValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .redAlert:
            try container.encode("ALERTA_VERMELHO")
        case .high:
            try container.encode("ALTA")
        case .medium:
            try container.encode("MEDIA")
        case .low:
            try container.encode("BAIXA")
        }
    }

    var color: UIColor {
        switch self {
        case .low:
            return .appCyan
        case .medium:
            return .systemOrange
        case .redAlert:
            return .appRed
        default:
            return .appRed
        }
    }

    enum AnswerError: Error {
        case missingValue
    }

    public static func < (lhs: OccurrencePriority, rhs: OccurrencePriority) -> Bool {
        switch lhs {
        case .redAlert:
            return false
        case .high:
            switch rhs {
            case .redAlert: return true
            default: return false
            }
        case .medium:
            switch rhs {
            case .redAlert: return true
            case .high: return true
            default: return false
            }
        case .low:
            switch rhs {
            case .low: return false
            default: return true
            }
        }
    }
}

public enum OccurrenceSituation: String, Codable {
    case canceled = "Cancelado"
    case dispatched = "Despachado"
    case dispatchedEnded = "Despacho Finalizado"
    case notDispatched = "Não Despachado"
    case undefinedRegion = "Região Indefinida"
    case withoutOperator = "Sem Operador"
    case withoutRegion = "Sem Região"
    case all = "Todos"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringForRawValues = try container.decode(String.self)

        switch stringForRawValues {
        case "CANCELADO":
            self = .canceled
        case "DESPACHADO":
            self = .dispatched
        case "FINALIZADO_DESPACHO":
            self = .dispatchedEnded
        case "NAO_DESPACHADO":
            self = .notDispatched
        case "REGIAO_INDEFINIDA":
            self = .undefinedRegion
        case "SEM_OPERADOR":
            self = .withoutOperator
        case "SEM_REGIAO":
            self = .withoutRegion
        case "TODOS":
            self = .all
        default:
            throw AnswerError.missingValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .canceled:
            try container.encode("CANCELADO")
        case .dispatched:
            try container.encode("DESPACHADO")
        case .dispatchedEnded:
            try container.encode("FINALIZADO_DESPACHO")
        case .notDispatched:
            try container.encode("NAO_DESPACHADO")
        case .undefinedRegion:
            try container.encode("REGIAO_INDEFINIDA")
        case .withoutOperator:
            try container.encode("SEM_OPERADOR")
        case .withoutRegion:
            try container.encode("SEM_REGIAO")
        case .all:
            try container.encode("TODOS")
        }
    }

    enum AnswerError: Error {
        case missingValue
    }
}

public struct OccurrenceGeneralInfo: Codable {
    public let generalAlert: Bool
    public let abandoned: Bool
    public let priority: OccurrencePriority
    public let situation: OccurrenceSituation
    public let `protocol`: String
    public let mainOccurrenceId: UUID?
    public let serviceRegisteredAt: DateTimeWithTimeZone
    public let occurrenceRegisteredAt: DateTimeWithTimeZone
    public let generalAlertClassificationDateTime: String?
}

public struct Dispatch: Codable {
    public let dateTime: String
    public let team: SimpleTeam
    public let timeZone: String
    public let `operator`: Operator
    public let report: String?
    public let status: String

    public func getDate(format: String) -> Date? {
        return dateTime.toDate(format: format)?.fromUTCTo(timeZone)
    }
}

public struct SimpleTeam: Codable, Hashable {
    public let name: String
    public let id: UUID

    public static func == (lhs: SimpleTeam, rhs: SimpleTeam) -> Bool {
        lhs.id == rhs.id
    }
}

public struct CaptureRegion: Codable {
    public let initials: String
    public let name: String
    public let captureCenter: CaptureCenter
}

public struct CaptureCenter: Codable {
    public let initials: String
    public let name: String
}

public struct History: Codable {
    public let dateTime: String
    public let owner: Operator?
    public let eventType: String
    public let eventDescription: String
}

public struct Nature: Codable {
    public let id: UUID
    public let name: String
    public let priority: String?
    public let fieldsGroups: [FieldsGroup]?

    public func toBasic() -> BasicNature {
        BasicNature(id: id, name: name)
    }
}

public struct BasicNature: Codable, Hashable {
    public let id: UUID
    public let name: String

    public static func == (lhs: BasicNature, rhs: BasicNature) -> Bool {
        lhs.id == rhs.id
    }
}

public struct FieldsGroup: Codable {
    public let fields: [Field]
    public let name: String
}

public struct Field: Codable {
    public let name: String
    public let value: String
}

enum OccurrenceObjectType {
    case weapon, drug, involved, vehicle
}

protocol OccurrenceObject: Codable {
    associatedtype ObjectTypeUpdate: OccurrenceObjectUpdate

    var id: UUID { get }
    var version: Int { get }

    func getType() -> OccurrenceObjectType
    func hasExternalId() -> Bool
    func toUpdate(teamId: UUID, idsVersions: [IdVersion]) -> ObjectTypeUpdate
}

public struct Drug: OccurrenceObject {
    typealias ObjectTypeUpdate = DrugUpdate

    public var id: UUID
    public var version: Int
    public let natures: [String]
    public let externalId: UUID?
    public let destination: String?
    public let `package`: String?
    public let note: String?
    public let amount: String?
    public let situation: String?
    public let apparentType: String?
    public let measureUnit: String?
    public let bondWithInvolved: String?

    func toUpdate(teamId: UUID, idsVersions: [IdVersion]) -> DrugUpdate {
        let newExternalId = externalId ?? UUID()
        let mergeExternalIds = externalId == nil ? [id] : []
        return DrugUpdate(
            teamId: teamId,
            drugs: idsVersions,
            externalId: externalId,
            newExternalId: newExternalId,
            destination: destination,
            package: package,
            note: note,
            quantity: amount,
            apparentType: apparentType,
            measureUnit: measureUnit,
            bondWithInvolved: bondWithInvolved,
            mergeExternalIds: mergeExternalIds
        )
    }

    func getType() -> OccurrenceObjectType { .drug }

    func hasExternalId() -> Bool { externalId != nil }
}

public struct Involved: OccurrenceObject {
    typealias ObjectTypeUpdate = InvolvedUpdate

    public var id: UUID
    public var version: Int
    public let externalId: UUID?
    public let birthDate: String?
    public let involvement: String?
    public let natures: [String]
    public let name: String?
    public let motherName: String?
    public let documentNumber: String?
    public let warrantNumber: String?
    public let colorRace: String?
    public let gender: String?
    public let organInitials: String?
    public let documentType: String?
    public let note: String?

    func toUpdate(teamId: UUID, idsVersions: [IdVersion]) -> InvolvedUpdate {
        let newExternalId = externalId ?? UUID()
        let parsedBirthDate = birthDate?.toDate(format: "yyyy-MM-dd")?.difference(to: Date(), [.year])
        let mergeExternalIds = externalId == nil ? [id] : []
        return InvolvedUpdate(
            externalId: externalId,
            teamId: teamId,
            involved: idsVersions,
            newExternalId: newExternalId,
            birthDate: birthDate,
            age: parsedBirthDate.flatMap { $0.year }.map { "\($0)" },
            name: name,
            motherName: motherName,
            warrantNumber: warrantNumber,
            colorRace: colorRace,
            gender: gender,
            organInitials: organInitials,
            documentNumber: documentNumber,
            documentType: documentType,
            note: note,
            mergeExternalIds: mergeExternalIds
        )
    }

    func getType() -> OccurrenceObjectType { .involved }

    func hasExternalId() -> Bool { externalId != nil }
}

public struct Weapon: OccurrenceObject {
    typealias ObjectTypeUpdate = WeaponUpdate

    public var id: UUID
    public var version: Int
    public let natures: [String]
    public let externalId: UUID?
    public let caliber: String?
    public let destination: String?
    public let specie: String?
    public let manufacture: String?
    public let brand: String?
    public let model: String?
    public let serialNumber: String?
    public let sinarmSigmaNumber: String?
    public let note: String?
    public let situation: String?
    public let `type`: String?
    public let bondWithInvolved: String?

    func toUpdate(teamId: UUID, idsVersions: [IdVersion]) -> WeaponUpdate {
        let newExternalId = externalId ?? UUID()
        let mergeExternalIds = externalId == nil ? [id] : []
        return WeaponUpdate(
            teamId: teamId,
            weapons: idsVersions,
            externalId: newExternalId,
            newExternalId: newExternalId,
            caliber: caliber,
            destination: destination,
            specie: specie,
            manufacture: manufacture,
            brand: brand,
            model: model,
            serialNumber: serialNumber,
            sinarmSigmaNumber: sinarmSigmaNumber,
            note: note,
            type: type,
            bondWithInvolved: bondWithInvolved,
            mergeExternalIds: mergeExternalIds
        )
    }

    func getType() -> OccurrenceObjectType { .weapon }

    func hasExternalId() -> Bool { externalId != nil }
}

public struct Location: Codable {
    public let district: String?
    public let ibgeCityCode: String?
    public let complement: String?
    public let coordinates: LocationCoordinates?
    public let km: String?
    public let street: String?
    public let city: String?
    public let number: String?
    public let highwayLane: String?
    public let referencePoint: String?
    public let highway: String?
    public let roadDirection: String?
    public let placeType: Int?
    public let placeTypeDescription: String?
    public let roadType: String?
    public let stretch: String?
    public let state: String?
    public let version: Int

    public func toAddress() -> OccurrenceAddress? {
        if let city = city,
           let state = state,
           let latitude = coordinates?.latitude,
           let longitude = coordinates?.longitude {
            return OccurrenceAddress(
                street: street,
                district: district,
                city: city,
                state: state,
                addressType: placeTypeDescription,
                latitude: latitude,
                longitude: longitude
            )
        }
        return nil
    }

    public func getFormattedAddress(withCoordinates: Bool = false) -> String {
        var formattedAddress = String.interpolateString(
            values: [street, number, district, city, state],
            separators: [" ", ", ", ", ", " - "]
        )
        if let roadType = roadType, ["RODOVIA_FEDERAL", "RODOVIA_ESTADUAL"].contains(roadType) {
            formattedAddress = String.interpolateString(
                values: [highway, km, city, state],
                separators: [", km ", ", ", " - "]
            )
        }
        if withCoordinates {
            let coordinatesString = String.interpolateString(
                values: [(coordinates?.latitude).map { String($0) }, (coordinates?.longitude).map { String($0) }],
                separators: [", "]
            )
            formattedAddress = formattedAddress + ", " + coordinatesString
        }
        return formattedAddress
    }
}

public struct LocationCoordinates: Codable {
    public let latitude: Double
    public let longitude: Double

    public func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude,
                               longitude: longitude)
    }

    public func toCLLocation() -> CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

public struct ComplementaryOccurrence: Codable {
    public let serviceRegisteredAt: DateTimeWithTimeZone?
    public let address: Location
    public let natures: [NatureSimple]
    public let priority: OccurrencePriority
    public let `protocol`: String
    public let situation: OccurrenceSituation
    public let id: UUID
}

public struct DateTimeWithTimeZone: Codable {
    public let dateTime: String
    public let timeZone: String
    
    public func toDate(format: String, timezoned: Bool = true) -> Date? {
        let formattedDate = dateTime.toDate(format: format)
        if timezoned {
            return formattedDate?.fromUTCTo(timeZone)
        }
        return formattedDate
    }

    public func format() -> String {
        let formatted = toDate(format: "yyyy-MM-dd'T'HH:mm:ss")?
            .format(to: "dd/MM/yyyy HH:mm:ss")
        return formatted.map { s in "\(s) \(timeZone)" } ?? String.emptyProperty
    }
}

public struct NatureSimple: Codable {
    public let name: String
    public let priority: String
    public let id: UUID
}

public struct Vehicle: OccurrenceObject {
    typealias ObjectTypeUpdate = VehicleUpdate

    public let id: UUID
    public let version: Int
    public let externalID: UUID?
    public let characteristics: String?
    public let chassis: String?
    public let moveCondition: String?
    public let color: String?
    public let involvement: String?
    public let escaped: String?
    public let brand: String?
    public let model: String?
    public let natures: [String]
    public let plate: String?
    public let restriction: String?
    public let robberyTheft: String?
    public let `type`: String?
    public let bondWithInvolved: String?
    public let note: String?

    func toUpdate(teamId: UUID, idsVersions: [IdVersion]) -> VehicleUpdate {
        let newExternalId = externalID ?? UUID()
        let mergeExternalIds = externalID == nil ? [id] : []
        return VehicleUpdate(
            teamId: teamId,
            vehicles: idsVersions,
            externalId: externalID,
            newExternalId: newExternalId,
            characteristics: characteristics,
            chassis: chassis,
            moveCondition: moveCondition,
            color: color,
            escaped: escaped,
            brand: brand,
            model: model,
            plate: plate,
            restriction: restriction,
            robberyTheft: robberyTheft,
            type: type,
            note: note,
            bondWithInvolved: bondWithInvolved,
            mergeExternalIds: mergeExternalIds
        )
    }

    func getType() -> OccurrenceObjectType { .vehicle }

    func hasExternalId() -> Bool { externalID != nil }
}

public struct PlaceType: Codable, Hashable {
    public let code: String
    public let description: String

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    public static func == (lhs: PlaceType, rhs: PlaceType) -> Bool {
        return lhs.code == rhs.code
    }
}
