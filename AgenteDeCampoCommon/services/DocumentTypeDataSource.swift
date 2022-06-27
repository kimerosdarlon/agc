//
//  DocumentTypeDataSource.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 20/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public struct DocumentType {
    public let name: String
    public let code: Int
    public var patterns = [String]()
    public var mask: String?
    public var keyboardType: UIKeyboardType

    public init(document: APIDocumentType) {
        name = document.name
        code = document.id
        keyboardType = .alphabet
        if name.lowercased().starts(with: "cpf") {
            patterns = [AppRegex.cpfPattern]
            mask = AppMask.cpfMask
            keyboardType = .numberPad
        } else if name.lowercased().elementsEqual("cnpj") {
            patterns = [AppRegex.cnpjPattern]
            mask = AppMask.cnpjMask
            keyboardType = .numberPad
        }
    }

    public func isValid(value: String) -> Bool {
        if patterns.isEmpty {
            return true
        }
        return value.isCPF || value.isCNPJ
    }
}

public protocol DocumentTypeDataSourceDelegate: class {
    func didSelect(document: DocumentType)
}

public class DocumentTypeDataSource: NSObject {

    public weak var delegate: DocumentTypeDataSourceDelegate?
    private var documents = [DocumentType]()
    public var filter: ((DocumentType) -> Bool)?

    public init(documents: [DocumentType]) {
        super.init()
        self.documents = documents
        self.documents.insert(DocumentType(document: APIDocumentType(name: "", id: 0) ), at: 0)
    }
}

extension DocumentTypeDataSource: UIPickerViewDataSource, UIPickerViewDelegate {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let filter = self.filter {
            return documents.filter(filter).count
        }
        return documents.count
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelect(document: documents[row])
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return documents[row].name
    }
}
