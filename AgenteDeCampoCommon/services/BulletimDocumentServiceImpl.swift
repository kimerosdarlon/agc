//
//  OccurrenceBulletinServiceImpl.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 20/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import RestClient

@propertyWrapper
public struct BulletimDocumentServiceInject {

    private var value: BulletimDocumentService

    public init() {
        self.value = BulletimDocumentServiceImpl()
    }

    public var wrappedValue: BulletimDocumentService {
        get { value }
        set {
            value = newValue
        }
    }
}

private class BulletimDocumentServiceImpl: BulletimDocumentService {

    public init() {
    }

    private static var bulletimDocuments = [APIDocumentType]()

    public func getDocuments() -> [APIDocumentType] {
        return BulletimDocumentServiceImpl.bulletimDocuments
    }

    public func loadAll(completion: @escaping (Result<[APIDocumentType], Error>) -> Void ) {
        guard let token =  TokenService().getApplicationToken() else {
            return
        }
        let rest = RestTemplateBuilder(enviroment: ACEnviroment.shared)
            .addToken(token: token).acceptJson().path("/search/bulletins/documents")
            .build()
        rest?.get(completion: { (result: Result<[APIDocumentType], Error> ) in
            switch result {
            case .success(let documents):
                BulletimDocumentServiceImpl.bulletimDocuments = documents
                completion(.success(documents))
            case .failure(let error):
                completion(.failure(error))
                NSLog("%@", error.localizedDescription)
            }
        })
    }

    public func setupDocument( _ delegate: DocumentTypeDataSourceDelegate, withType type: String? ) {
        if let documentType = type,
            let id = Int(documentType) {
            if let document = getDocuments().first(where: {$0.id == id}) {
                garanteeMainThread {
                    delegate.didSelect(document: DocumentType(document: document) )
                }
            }
        }
    }
}
