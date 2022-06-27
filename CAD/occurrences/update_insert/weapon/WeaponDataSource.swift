//
//  WeaponDataSource.swift
//  CAD
//
//  Created by Samir Chaves on 22/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

class WeaponDataSource {

    @domainServiceInject
    private var domainService: DomainService

    private(set) var domainData: WeaponsDomain?

    var selectedType: String?

    func fetchData(completion: @escaping (Error?) -> Void) {
        domainService.getWeaponsData { result in
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
