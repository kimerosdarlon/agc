//
//  GeocodingService.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 19/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import RestClient

public class Service {
    var enviroment = ACEnviroment.shared
    var token: String {
        TokenService().getApplicationToken() ?? ""
    }

    open var client: RestTemplateBuilder {
        return RestTemplateBuilder(enviroment: self.enviroment).addToken(token: token)
        .acceptJson()
    }
}

public protocol GeocodingService {
    func geocode(address: String, completion: @escaping (Result<[GeocodeResult], Error>) -> Void)
    func reverseGeocode(lat: Double, lng: Double, completion: @escaping (Result<ReverseGeocode, Error>) -> Void)
}

public class GeocodingServiceImpl: Service, GeocodingService {
    public func geocode(address: String, completion: @escaping (Result<[GeocodeResult], Error>) -> Void) {
        let rest = client
            .path("/geocode")
            .params([
                "address": address
            ])
            .build()

        rest?.get(completion: completion)
    }

    public func reverseGeocode(lat: Double, lng: Double, completion: @escaping (Result<ReverseGeocode, Error>) -> Void) {
        let rest = client
            .path("/geocode/reverse?lat=\(lat)&lon=\(lng)")
            .build()

        rest?.get(completion: completion)
    }
}

@propertyWrapper
public struct GeocodingServiceInject {
    private var value: GeocodingService

    public init() {
        self.value = GeocodingServiceImpl()
    }

    public var wrappedValue: GeocodingService { value }
}
