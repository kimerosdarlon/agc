//
//  WarrantFilterFormModel.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 19/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon

class WarrantFilterFormModel: ModelForm {

    let service = WarrantDocumentService()

    var name: String?
    var nickName: String?
    var motherName: String?
    var processNumber: String?
    var state: String?
    var city: String?
    var documentType: String?
    var documentNumber: String?

    var params = [String: Any]()

    func getInfo() -> [String: String] {
        var infos = [String: String]()
        if let name = name, !name.isEmpty { infos["Nome"] = name }
        if let nickName = nickName, !nickName.isEmpty { infos["Alcunha"] = nickName }
        if let motherName = motherName, !motherName.isEmpty { infos["Mãe"] = motherName }
        if let processNumber = processNumber, !processNumber.isEmpty { infos["Processo"] = processNumber }
        if let state = state, !state.isEmpty { infos["Estado"] = state }
        if let city = city, !city.isEmpty { infos["Cidade"] = city }
        if let documentType = documentType, !documentType.isEmpty,
            let documentNumber = documentNumber, !documentNumber.isEmpty {
            if let documentName = service.getDocuments().filter({$0.name == documentType }).first?.name ?? service.getDocuments().filter({ $0.id == Int(documentType) }).first?.name {
                infos[documentName] = documentNumber
            }
        }
        return infos
    }

    func queryParams() throws -> [String: Any] {
        try check(key: documentType, value: documentNumber, error: .documentIsEmpty)
        if params.isEmpty {
            let error = ApplicationErrors.paramsIsEmpty
            throw NSError(domain: error.message, code: error.code, userInfo: nil)
        }
        return params
    }

    func check(key: String?, value: String?, error: ApplicationErrors ) throws {
        if (key != nil && !key!.isEmpty) && (value == nil || value!.isEmpty ) {
            throw NSError(domain: error.message, code: error.code, userInfo: nil)
        }
    }

    fileprivate func setDocumentType(_ value: String?, _ property: String) {
        if let strCode = value, let code = Int(strCode) {
            if code > 0 {
                self.documentType = "\(code)"
                params[property] = self.documentType
            } else {
                self.documentType = nil
                params[property] = nil
            }
        } else {
            self.documentType = nil
            params[property] = nil
        }
    }

    fileprivate func setCity(_ value: String?, _ property: String) {
        if let strCode = value {
            if let code = Int(strCode), code > 0 {
                self.city = "\(code)"
                params[property] = self.city
            }
        } else {
            self.city = nil
            params[property] = nil
        }
    }

    fileprivate func setState(_ value: String?, _ property: String) {
        if let state = value {
            if state.count == 2 {
                self.state = state
                params[property] = self.state
            }
         } else {
            self.state = nil
            params[property] = nil
        }
    }

    func set(value: String?, path: ReferenceWritableKeyPath<WarrantFilterFormModel, String?>) {
        self[keyPath: path] = value
        let property = path.stringValue
        if path == \.state {
            setState(value, property)
        } else if path == \.city {
            setCity(value, property)
        } else if path == \.documentType {
            setDocumentType(value, property)
        } else if path == \.processNumber {
            params[property] = value?.onlyNumbers()
        } else {
            params[property] = value
        }

        if let value = value {
            if value.isEmpty {
                params[property] = nil
            }
        }
    }
}

extension ReferenceWritableKeyPath where Root == WarrantFilterFormModel {
    var stringValue: String {
        switch self {
        case \WarrantFilterFormModel.name: return "name"
        case \WarrantFilterFormModel.nickName: return "nickName"
        case \WarrantFilterFormModel.motherName: return "motherName"
        case \WarrantFilterFormModel.processNumber: return "proccessorNumber"
        case \WarrantFilterFormModel.state: return "dispatcherState"
        case \WarrantFilterFormModel.city: return "dispatcherCity"
        case \WarrantFilterFormModel.documentType: return "documentType"
        case \WarrantFilterFormModel.documentNumber: return "documentNumber"
        default: fatalError("Unexpected key path")
        }
    }
}
