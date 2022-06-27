//
//  InvolvedDataSource.swift
//  CAD
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

class InvolvedDataSource {

    @domainServiceInject
    private var domainService: DomainService

    var domainData: InvolvedsDomain?

    func fetchData(completion: @escaping (Error?) -> Void) {
        domainService.getInvolvedsData { result in
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
