//
//  DocumentService.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 21/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import RestClient

public class WarrantDocumentService {

    public init() {
    }

    private static var warrantDocuments = [APIDocumentType]()

    public func getDocuments() -> [APIDocumentType] {
        return WarrantDocumentService.warrantDocuments
    }

    public func loadAll(completion: @escaping (Result<[APIDocumentType], Error>) -> Void ) {
        guard let token =  TokenService().getApplicationToken() else {
            return
        }
        let rest = RestTemplateBuilder(enviroment: ACEnviroment.shared)
            .addToken(token: token).acceptJson().path("/search/warrants/documents")
            .build()
        rest?.get(completion: { (result: Result<[APIDocumentType], Error> ) in
            switch result {
            case .success(let documents):
                WarrantDocumentService.warrantDocuments = documents
                completion(.success(documents))
            case .failure(let error):
                completion(.failure(error))
                NSLog("%@", error.localizedDescription)
            }
        })
    }
}
