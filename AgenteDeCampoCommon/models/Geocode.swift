//
//  Geocode.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 19/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import CoreLocation

public struct RouteNumberValue: Codable {
    public let stringValue: String
    public let intValue: Int

    public init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()

        do {
            stringValue = try container.decode(String.self)
            intValue = .min
        } catch {
            intValue = try container.decode(Int.self)
            stringValue = ""
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try stringValue.isEmpty ? container.encode(intValue) : container.encode(stringValue)
    }
}

public struct RouteNumber: Codable {
    private let value: RouteNumberValue
}

public struct GeocodeAddress: Codable {
    public let country: String?
    public let countryCode: String?
    public let countryCodeISO3: String?
    public let countrySecondarySubdivision: String?
    public let countrySubdivision: String?
    public let countrySubdivisionName: String?
    public let countryTertiarySubdivision: String?
    public let crossStreet: String?
    public let buildingNumber: String?
    public let extendedPostalCode: String?
    public let freeformAddress: String?
    public let localName: String?
    public let municipality: String?
    public let municipalitySubdivision: String?
    public let postalCode: String?
//    public let routeNumbers: [RouteNumber]?
    public let street: String?
    public let streetName: String?
    public let streetNameAndNumber: String?
    public let streetNumber: String?
}

public struct GeocodeCoordinate: Codable {
    public let lat: Double
    public let lon: Double

    public func toCLCoordinate() -> CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }
}

public struct GeocodeResult: Codable {
    public let position: GeocodeCoordinate
    public let address: GeocodeAddress
}

public struct ReverseGeocodeResult: Codable {
  public let address: GeocodeAddress
  public let matchType: String?
  public let position: String
}

public struct ReverseGeocode: Codable {
    public let addresses: [ReverseGeocodeResult]
}

