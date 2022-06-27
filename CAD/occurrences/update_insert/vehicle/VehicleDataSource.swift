//
//  VehicleDataSource.swift
//  CAD
//
//  Created by Samir Chaves on 16/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

class VehicleDataSource {

    @domainServiceInject
    private var domainService: DomainService

    var domainData: VehiclesDomain?

    func fetchData(completion: @escaping (Error?) -> Void) {
        domainService.getVehiclesData { result in
            switch result {
            case .success(let domainData):
                self.domainData = domainData
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
