//
//  CadFilterViewModel.swift
//  CAD
//
//  Created by Ramires Moreira on 11/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import Combine

protocol CadFilterViewModelDelegate: class {
    func didFieldValueChange()
}

typealias CadFilterSearchField = [String: Any?]

class CadFilterViewModel {
    weak var delegate: CadFilterViewModelDelegate?
    var `protocol` = CurrentValueSubject<String?, Never>(nil)
    var person = CurrentValueSubject<String?, Never>(nil)
    var agency = CurrentValueSubject<String?, Never>(nil)
    var situations = CurrentValueSubject<Set<String>, Never>([])
    var nature = CurrentValueSubject<String?, Never>(nil)
    var dateRangeStart = CurrentValueSubject<String?, Never>(nil)
    var dateRangeEnd = CurrentValueSubject<String?, Never>(nil)
    var placeType = CurrentValueSubject<String?, Never>(nil)
    var street = CurrentValueSubject<String?, Never>(nil)
    var vehiclePlate = CurrentValueSubject<String?, Never>(nil)
    var state = CurrentValueSubject<String?, Never>(nil)
    var city = CurrentValueSubject<String?, Never>(nil)
    var district = CurrentValueSubject<String?, Never>(nil)
    var referencePoint = CurrentValueSubject<String?, Never>(nil)
    var operatingRegions = CurrentValueSubject<Set<String>, Never>([])
    var involvedName = CurrentValueSubject<String?, Never>(nil)
    var involvedCpf = CurrentValueSubject<String?, Never>(nil)
    var involvedBirthdate = CurrentValueSubject<String?, Never>(nil)
    var involvedMotherName = CurrentValueSubject<String?, Never>(nil)
    private var stringFields = [CurrentValueSubject<String?, Never>]()
    private var listFields = [CurrentValueSubject<Set<String>, Never>]()

    private var cancelables = [AnyCancellable]()
    private var params: [String: Any]

    init(params: [String: Any]) {
        self.params = params
        sink(paramKey: "personTeamId", with: person, transform: nil)
        person.send((params["personTeamId"] as? String))
        stringFields.append(person)

        sink(paramKey: "agencyId", with: agency, transform: nil)
        agency.send((params["agencyId"] as? String))
        stringFields.append(agency)

        sink(paramKey: "protocol", with: `protocol`, transform: nil)
        `protocol`.send((params["protocol"] as? String))
        stringFields.append(`protocol`)

        sink(paramKey: "situations", with: situations, transform: nil)
        situations.send((params["situations"] as? Set<String>) ?? Set())
        listFields.append(situations)

        sink(paramKey: "natureId", with: nature, transform: nil)
        nature.send((params["natureId"] as? String))
        stringFields.append(nature)

        sink(paramKey: "startDate", with: dateRangeStart, transform: nil)
        dateRangeStart.send((params["startDate"] as? String))
        stringFields.append(dateRangeStart)

        sink(paramKey: "endDate", with: dateRangeEnd, transform: nil)
        dateRangeEnd.send((params["endDate"] as? String))
        stringFields.append(dateRangeEnd)

        sink(paramKey: "placeType", with: placeType, transform: nil)
        placeType.send((params["placeType"] as? String))
        stringFields.append(placeType)

        sink(paramKey: "vehiclePlate", with: vehiclePlate, transform: nil)
        vehiclePlate.send((params["vehiclePlate"] as? String))
        stringFields.append(vehiclePlate)

        sink(paramKey: "street", with: street, transform: nil)
        street.send((params["street"] as? String))
        stringFields.append(street)

        sink(paramKey: "state", with: state, transform: nil)
        state.send((params["state"] as? String))
        stringFields.append(state)

        sink(paramKey: "city", with: city, transform: nil)
        city.send((params["city"] as? String))
        stringFields.append(city)

        sink(paramKey: "district", with: district, transform: nil)
        district.send((params["district"] as? String))
        stringFields.append(district)

        sink(paramKey: "referencePoint", with: referencePoint, transform: nil)
        referencePoint.send((params["referencePoint"] as? String))
        stringFields.append(referencePoint)

        sink(paramKey: "operatingRegionsIds", with: operatingRegions, transform: nil)
        operatingRegions.send((params["operatingRegionsIds"] as? Set<String>) ?? Set())
        listFields.append(operatingRegions)

        sink(paramKey: "involvedName", with: involvedName, transform: nil)
        involvedName.send((params["involvedName"] as? String))
        stringFields.append(involvedName)

        sink(paramKey: "involvedCPF", with: involvedCpf, transform: {$0.onlyNumbers()})
        involvedCpf.send((params["involvedCPF"] as? String)?.applyCpfORCnpjMask)
        stringFields.append(involvedCpf)

        sink(paramKey: "involvedBirthday", with: involvedBirthdate, transform: nil)
        involvedBirthdate.send((params["involvedBirthday"] as? String))
        stringFields.append(involvedBirthdate)

        sink(paramKey: "involvedMotherName", with: involvedMotherName, transform: nil)
        involvedMotherName.send((params["involvedMotherName"] as? String))
        stringFields.append(involvedMotherName)
    }

    enum CadFilterValidation: String, CustomStringConvertible, Error {
        case myOccurrences = "Os filtros de data inicial e final são obrigatórios ao buscar por suas próprias ocorrências."
        case involved = "Data de nascimento ou nome da mãe precisam ser informados junto do nome do envolvido"
        case agency = "O filtro de agência é obrigatório quando a busca não envolva filtros relacionados a envolvidos, veículo ou suas ocorrências."

        var description: String {
            return self.rawValue
        }
    }

    private func isFieldValid(_ field: CurrentValueSubject<String?, Never>) -> Bool {
        return field.value != nil && !field.value!.isEmpty
    }

    private func validateMyOccurrences() throws {
        if isFieldValid(person) && (!isFieldValid(dateRangeStart) || !isFieldValid(dateRangeEnd)) {
            throw CadFilterValidation.myOccurrences
        }
    }

    private func validateInvolved() throws {
        if isFieldValid(involvedName) && !isFieldValid(involvedMotherName) && !isFieldValid(involvedBirthdate) {
            throw CadFilterValidation.involved
        }
    }

    private func validateAgency() throws {
        // Fields allowed to be used without provide an agency
        let allowedFields = [vehiclePlate, involvedCpf, involvedBirthdate, involvedName, involvedMotherName, person]
        if !isFieldValid(agency) && allowedFields.allSatisfy({ !isFieldValid($0) }) {
            throw CadFilterValidation.agency
        }
    }

    func validateInput() throws {
        let validator = FormValidator()
        try validator.checkProtocol(string: `protocol`.value)
        try validator.checkPlate(string: vehiclePlate.value)
        try validator.checkCPFAndCnpjInput(string: involvedCpf.value)
        try validateMyOccurrences()
        try validateInvolved()
        try validateAgency()
    }

    func sink(paramKey key: String, with subject: CurrentValueSubject<String?, Never>,
              transform: ((String) -> String)? = nil) {
        let cancellable = subject.sink { (optionalValue) in
            guard let value = optionalValue else { return }
            let tranformableValue = transform?(value) ?? value
            self.params[key] = tranformableValue.isEmpty ? nil : tranformableValue
            self.delegate?.didFieldValueChange()
        }
        cancelables.append(cancellable)
    }

    func sink(paramKey key: String, with subject: CurrentValueSubject<Set<String>, Never>,
              transform: ((Set<String>) -> Set<String>)? = nil ) {
        let cancellable = subject.sink { (value) in
            var tranformableValue = value
            if let transform = transform {
                tranformableValue = transform(value)
            }
            self.params[key] = tranformableValue.isEmpty ? nil : tranformableValue
            self.delegate?.didFieldValueChange()
        }
        cancelables.append(cancellable)
    }

    static func getInfo(from params: [String: String]) -> [String: String] {
        var info = [
            "Pessoa": params["personTeamId"],
            "Agência": params["agencyId"],
            "Protocolo": params["protocol"],
            "Situações": params["situations"],
            "Natureza": params["natureId"],
            "Data e hora inicial": params["startDate"],
            "Data e hora final": params["endDate"],
            "Tipo de local": params["placeType"],
            "Logradouro": params["street"],
            "Estado UF": params["state"],
            "Cidade": params["city"],
            "Bairro": params["district"],
            "Placa": params["vehiclePlate"],
            "Ponto de Referência": params["referencePoint"],
            "Regiões de Atuação": params["operatingRegionsIds"],
            "Nome": params["involvedName"],
            "CPF": params["involvedCPF"],
            "Data de Nascimento": params["involvedBirthday"],
            "Nome da mãe": params["involvedMotherName"]
        ]

        let keysToRemove = info.keys.filter { info[$0]! == nil || info[$0]!!.isEmpty }

        for key in keysToRemove {
            info.removeValue(forKey: key)
        }

        let result = (info as? [String: String]) ?? [:]
        return result
    }

    func getSearchString(_ info: [String: String]) -> [String: CadFilterSearchField] {
        let query = queryParams()
        var searchString: [String: CadFilterSearchField] = [
            "personTeamId": ["serviceValue": query["personTeamId"], "userValue": info["Pessoa"]],
            "agencyId": ["serviceValue": query["agencyId"], "userValue": info["Agência"]],
            "protocol": ["serviceValue": query["protocol"], "userValue": info["Protocolo"]],
            "situations": ["serviceValue": query["situations"], "userValue": info["Situações"]],
            "natureId": ["serviceValue": query["natureId"], "userValue": info["Natureza"]],
            "startDate": ["serviceValue": query["startDate"], "userValue": info["Data e hora inicial"]],
            "endDate": ["serviceValue": query["endDate"], "userValue": info["Data e hora final"]],
            "placeType": ["serviceValue": query["placeType"], "userValue": info["Tipo de local"]],
            "street": ["serviceValue": query["street"], "userValue": info["Logradouro"]],
            "state": ["serviceValue": query["state"], "userValue": info["Estado UF"]],
            "city": ["serviceValue": query["city"], "userValue": info["Cidade"]],
            "district": ["serviceValue": query["district"], "userValue": info["Bairro"]],
            "vehiclePlate": ["serviceValue": query["vehiclePlate"], "userValue": info["Placa"]],
            "referencePoint": ["serviceValue": query["referencePoint"], "userValue": info["Ponto de Referência"]],
            "operatingRegionsIds": ["serviceValue": query["operatingRegionsIds"], "userValue": info["Regiões de Atuação"]],
            "involvedName": ["serviceValue": query["involvedName"], "userValue": info["Nome"]],
            "involvedCPF": ["serviceValue": query["involvedCPF"], "userValue": info["CPF"]],
            "involvedBirthday": ["serviceValue": query["involvedBirthday"], "userValue": info["Data de Nascimento"]],
            "involvedMotherName": ["serviceValue": query["involvedMotherName"], "userValue": info["Nome da mãe"]]
        ]

        let keysToRemove = searchString.keys.filter { key in
            searchString[key]?["serviceValue"] == nil || searchString[key]!["serviceValue"]! == nil
        }

        for key in keysToRemove {
            searchString.removeValue(forKey: key)
        }

        return searchString
    }

    func queryParams() -> [String: Any] {
        var query = [
            "personTeamId": (params["personTeamId"] as? String),
            "agencyId": (params["agencyId"] as? String),
            "protocol": (params["protocol"] as? String),
            "situations": (params["situations"] as? [String]),
            "natureId": (params["natureId"] as? String),
            "startDate": (params["startDate"] as? String),
            "endDate": (params["endDate"] as? String),
            "placeType": (params["placeType"] as? String),
            "street": (params["street"] as? String),
            "state": (params["state"] as? String),
            "city": (params["city"] as? String),
            "vehiclePlate": (params["vehiclePlate"] as? String)?.replacingOccurrences(of: "-", with: "").lowercased(),
            "district": (params["district"] as? String),
            "referencePoint": (params["referencePoint"] as? String),
            "operatingRegionsIds": (params["operatingRegionsIds"] as? [String]),
            "involvedName": (params["involvedName"] as? String),
            "involvedCPF": (params["involvedCPF"] as? String)?.onlyNumbers(),
            "involvedBirthday": (params["involvedBirthday"] as? String),
            "involvedMotherName": (params["involvedMotherName"] as? String)
        ] as [String: Any?]

        let keysToRemove = query.keys.filter { query[$0]! == nil }

        for key in keysToRemove {
            query.removeValue(forKey: key)
        }

        return query as [String: Any]
    }
}
