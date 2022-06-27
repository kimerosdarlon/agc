//
//  DriverFilterFormModel.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 13/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon

class DriverFilterFormModel: ModelForm {

    let service = DriverSearchService()

    var cpf: String?
    var cnh: String?
    var renach: String?
    var pid: String?

    var params = [String: Any]()

    func validateInput() throws {
        let validator = FormValidator()
        try validator.checkCPFAndCnpjInput(string: params["cpf"])
        try validator.checkCnh(string: params["cnh"])
        try validator.checkRenach(string: params["renach"])
        try validator.checkPid(string: params["pid"])
    }

    func getInfo() -> [String: String] {
        var infos = [String: String]()

        if let cpf = cpf, !cpf.isEmpty { infos["cpf"] = cpf }
        if let cnh = cnh, !cnh.isEmpty { infos["cnh"] = cnh }
        if let renach = renach, !renach.isEmpty { infos["renach"] = renach }
        if let pid = pid, !pid.isEmpty { infos["pid"] = pid }

        return infos
    }

    func set(value: String?, path: ReferenceWritableKeyPath<DriverFilterFormModel, String?>) {
        self[keyPath: path] = value
        let property = path.stringValue

        if path == \.cpf || path == \.cnh {
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

extension ReferenceWritableKeyPath where Root == DriverFilterFormModel {
    var stringValue: String {
        switch self {
        case \DriverFilterFormModel.cpf: return "cpf"
        case \DriverFilterFormModel.cnh: return "cnh"
        case \DriverFilterFormModel.renach: return "renach"
        case \DriverFilterFormModel.pid: return "pid"
        default: fatalError("path não encontrado")
        }
    }
}
