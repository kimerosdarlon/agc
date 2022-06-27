//
//  DispatchStatus.swift
//  CAD
//
//  Created by Samir Chaves on 29/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public enum DispatchStatusCode: String, Codable {
    case dispatched = "EA"
    case moving = "ED"
    case arrived = "LO"
    case movingToIntermediatePlace = "DI"
    case arrivedAtIntermediatePlace = "CI"
    case finishedByIncident = "FI"
    case finishedByOperator = "FO"

    enum AnswerError: Error {
        case missingValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringForRawValues = try container.decode(String.self)

        switch stringForRawValues {
        case "EA":
            self = .dispatched
        case "ED":
            self = .moving
        case "LO":
            self = .arrived
        case "DI":
            self = .movingToIntermediatePlace
        case "CI":
            self = .arrivedAtIntermediatePlace
        case "FI":
            self = .finishedByIncident
        case "FO":
            self = .finishedByOperator
        default:
            throw AnswerError.missingValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

struct RawDispatchStatus: Codable {
    let code: DispatchStatusCode
    let description: String
    let requiresIntermediatePlace: Bool

    func updateDispatchStatus() {
        var iconName = ""
        switch code {
        case .moving:
            iconName = "statusDeslocamento"
        case .arrived:
            iconName = "statusChegadaLocal"
        case .movingToIntermediatePlace:
            iconName = "statusDeslocLocalInterm"
        case .arrivedAtIntermediatePlace:
            iconName = "statusChegadaLocalInterm"
        case .dispatched:
            iconName = "statusDespachado"
        default:
            iconName = ""
        }
        if !iconName.isEmpty,
           let image = UIImage(named: iconName) {
            let status = DispatchStatus(
                raw: self,
                icon: image,
                action: .keep
            )
            DispatchStatus.statusByCode[code] = status
        }
    }
}

private struct DispatchStatusDAG {
    static let dispatched: DispatchStatusCode = .moving
    static let moving: DispatchStatusCode = .arrived
    static let arrived: DispatchStatusCode = .movingToIntermediatePlace
    static let movingToIntermediatePlace: DispatchStatusCode = .arrivedAtIntermediatePlace
    static let arrivedAtIntermediatePlace: DispatchStatusCode = .movingToIntermediatePlace
}

public struct DispatchStatus {
    enum Action {
        case keep
        case finish
    }

    let raw: RawDispatchStatus
    let icon: UIImage
    let action: DispatchStatus.Action

    static private let flow: [DispatchStatusCode: DispatchStatusCode] = [
        .dispatched: .moving,
        .moving: .arrived,
        .arrived: .movingToIntermediatePlace,
        .movingToIntermediatePlace: .arrivedAtIntermediatePlace,
        .arrivedAtIntermediatePlace: .movingToIntermediatePlace
    ]

    static fileprivate var statusByCode = [DispatchStatusCode: DispatchStatus]()

    var next: DispatchStatus? {
        let nextStatusCode = DispatchStatus.flow[raw.code]!
        return DispatchStatus.statusByCode[nextStatusCode]
    }

    static var dispatched: DispatchStatus? { statusByCode[.dispatched] }
    static var moving: DispatchStatus? { statusByCode[.moving] }
    static var arrived: DispatchStatus? { statusByCode[.arrived] }
    static var movingToIntermediatePlace: DispatchStatus? { statusByCode[.movingToIntermediatePlace] }
    static var arrivedAtIntermediatePlace: DispatchStatus? { statusByCode[.arrivedAtIntermediatePlace] }

    public static func getStatusBy(code: DispatchStatusCode) -> DispatchStatus? {
        statusByCode[code]
    }
}
