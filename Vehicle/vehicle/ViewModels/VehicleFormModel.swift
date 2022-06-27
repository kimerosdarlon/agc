//
//  VehicleForm.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 29/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon

class VehicleFormViewModel: ModelForm {
    var plate: String?
    var chassis: String?
    var renavam: String?
    var motor: String?
    var possessor: String?
    var owner: String?
    var renter: String?
    private var params = [String: Any]()

    func queryParams() throws -> [String: Any] {
        setQueryParams()
        let validator = FormValidator()
        try validator.checkCPFAndCnpjInput(string: params["owner"])
        try validator.checkCPFAndCnpjInput(string: params["renter"])
        try validator.checkCPFAndCnpjInput(string: params["possessor"])
        try validator.checkPlate(string: params["plate"])
        if let term = params["termo"] as? String, !term.isEmpty {
            params["termo"] = nil
            return params
        }
        throw InputValidationError.empty
    }

    private func setQueryParams() {
        if let plate = plate, !plate.isEmpty { set(value: plate, path: \.plate) }
        if let chassis = chassis, !chassis.isEmpty { set(value: chassis, path: \.chassis) }
        if let renavam = renavam, !renavam.isEmpty { set(value: renavam, path: \.renavam) }
        if let motor = motor, !motor.isEmpty { set(value: motor, path: \.motor) }
        if let possessor = possessor, !possessor.isEmpty { set(value: possessor, path: \.possessor) }
        if let owner = owner, !owner.isEmpty { set(value: owner, path: \.owner) }
        if let renter = renter, !renter.isEmpty { set(value: renter, path: \.renter) }
    }

    func getInfo() -> [String: String] {
        var infos = [String: String]()
        if let plate = plate, !plate.isEmpty { infos["Placa"] = plate }
        if let chassis = chassis, !chassis.isEmpty { infos["Chassis"] = chassis }
        if let renavam = renavam, !renavam.isEmpty { infos["renavam"] = renavam }
        if let motor = motor, !motor.isEmpty { infos["motor"] = motor }
        if let possessor = possessor, !possessor.isEmpty { infos["Possuidor"] = possessor }
        if let owner = owner, !owner.isEmpty { infos["Prorietário"] = owner }
        if let renter = renter, !renter.isEmpty { infos["Locatário"] = renter }
        return infos
    }

    func set(value: String?, path: ReferenceWritableKeyPath<VehicleFormViewModel, String?>) {
        if let value = value, value != "" {
            clearAll()
            let property = path.stringValue
            params = [property: value.onlyStandardCharacters(), "type": property, "termo": value]
            self[keyPath: path] = value
        }
    }

    private func clearAll() {
        plate = nil
        chassis = nil
        renavam = nil
        motor = nil
        possessor = nil
        owner = nil
        renter = nil
    }
}

extension ReferenceWritableKeyPath where Root == VehicleFormViewModel {
    var stringValue: String {
        switch self {
        case \VehicleFormViewModel.plate: return "plate"
        case \VehicleFormViewModel.chassis: return "chassis"
        case \VehicleFormViewModel.renavam: return "renavam"
        case \VehicleFormViewModel.motor: return "motor"
        case \VehicleFormViewModel.possessor: return "possessor"
        case \VehicleFormViewModel.owner: return "owner"
        case \VehicleFormViewModel.renter: return "renter"
        default: fatalError("Unexpected key path")
        }
    }
}
