//
//  BulletimDocumentService.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 14/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public protocol BulletimDocumentService {
    func getDocuments() -> [APIDocumentType]
    func loadAll(completion: @escaping (Result<[APIDocumentType], Error>) -> Void )
    func setupDocument( _ delegate: DocumentTypeDataSourceDelegate, withType type: String? )
}
