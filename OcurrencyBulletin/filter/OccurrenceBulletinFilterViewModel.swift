//
//  OccurrenceBulletinViewModel.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 21/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import CoreDataModels
/// https://projetosenasp.atlassian.net/browse/AGC-3
/// Responsável por montar os filtros de busca de mandados
class OccurrenceBulletinFilterViewModel: ModelForm {

    @BulletimDocumentServiceInject
    private var bulletimService: BulletimDocumentService

    /// Parâmetros para a busca
    private var params = [String: Any]()

    /// cnpj: (Opcional) Número do CNPJ do envolvido;
    var cnpj: String?

    /// nomeFantasia: (Opcional) Nome fantasia da empresa envolvida;
    var nomeFantasia: String?

    /// name: (Opcional) Nome de registro, nome social ou alcunha do envolvido;
    var name: String?

    /// cpf: (Opcional) Número do CPF do envolvido;
    var cpf: String?

    /// motherName: (Opcional) Nome de registro da mãe do envolvido;
    var motherName: String?

    /// fatherName: (Opcional) Nome de registro do pai do envolvido;
    var fatherName: String?

    /// birthDate: (Opcional) Data de nascimento do envolvido no formato yyyy-mm-dd;
    var birthDate: String?

    /// licensePlate: (Opcional) Placa do veículo;
    var licensePlate: String?

    /// chassis: (Opcional) Chassi do veículo;
    var chassis: String?

    /// Owner: (Opcional) Dono do veículo;
    var owner: String?

    /// Owner: (Opcional) Dono do veículo;
    var ownerCpf: String?

    /// Possessor: (Opcional) Possuidor do veículo;
    var possessor: String?

    /// serialNumber: (Opcional) Número de série da arma.
    var serialNumber: String?

    /// imei: (Opcional) Número de série do celular.
    var imei: String?

    /// As iniciais do estado, exemplo: CE, PA, BH.
    var state: String? {
        didSet {
            if state == nil {
                set(value: nil, path: \.city)
            }
        }
    }

    /// O código da cidade que é disponibilidado na API.
    var city: String?

    /// código nacional do BO
    var nationalCode: String?

    /// código estadual do BO
    var stateCode: String?

    var documentType: String?

    var documentValue: String?

    private func setObjectsInfo(_ infos: inout [String: String]) {
        if let owner = owner, !owner.isEmpty { infos["Propietário"] = owner }
        if let ownerCpf = ownerCpf, !ownerCpf.isEmpty { infos["CPF"] = ownerCpf }
        if let possessor = possessor, !possessor.isEmpty { infos["Possuidor"] = possessor }
        if let imei = imei, !imei.isEmpty { infos["IMEI"] = imei }
        if let serial = serialNumber, !serial.isEmpty { infos["Nº de série"] = serial }
        if let chassis = chassis, !chassis.isEmpty { infos["Chassi"] = chassis }
        if let licensePlate = licensePlate, !licensePlate.isEmpty { infos["Placa"] = licensePlate.apply(pattern: AppMask.plateMask, replacmentCharacter: "#") }
    }

    private func setCompanyinfo(_ infos: inout [String: String]) {
        if let cnpj = cnpj, !cnpj.isEmpty { infos["CNPJ"] = cnpj.apply(pattern: AppMask.cnpjMask, replacmentCharacter: "#") }
        if let nomeFantasia = nomeFantasia, !nomeFantasia.isEmpty { infos["Empresa"] = nomeFantasia }
    }

    private func setPersonInfo(_ infos: inout [String: String]) {
        if let name = name, !name.isEmpty { infos["Nome"] = name }
        if let cpf = cpf, !cpf.isEmpty { infos["CPF"] = cpf.apply(pattern: AppMask.cpfMask, replacmentCharacter: "#") }
        if let motherName = motherName, !motherName.isEmpty { infos["Mãe"] = motherName }
        if let fatherName = fatherName, !fatherName.isEmpty { infos["Pai"] = fatherName }
        if let birthDate = birthDate, !birthDate.isEmpty { infos["Data Nasc"] = birthDate.split(separator: "-").reversed().joined(separator: "/") }
        if let fatherName = fatherName, !fatherName.isEmpty { infos["Pai"] = fatherName }
        if let documentType = documentType, !documentType.isEmpty {
            infos[documentType] = documentValue
        }
    }

    func setValuesFromSearch(params: [String: Any] ) {
        cnpj = params["cnpj"] as? String
        cpf = params["cpf"] as? String
        ownerCpf = params["owner.cpf"] as? String
        motherName = params["motherName"] as? String
        fatherName = params["fatherName"] as? String
        birthDate = params["birthDate"] as? String
        licensePlate = params["plate"] as? String
        chassis = params["chassis"] as? String
        owner = params["owner.name"] as? String
        possessor = params["possessor.name"] as? String
        serialNumber = params["serialNumber"] as? String
        imei = params["imei"] as? String

        if let stateInitials = params["bulletin.state"] as? String {
            let stateDataSource = StateDataSource()
            if let state = stateDataSource.findByInitials(stateInitials) {
                self.state = state.name
            }
        }

        if let cityCode = params["bulletin.city"] as? String {
            let cityDataSource = CityDataSource()
            if let city = cityDataSource.findByCode(cityCode) {
                self.city = city.name
            }
        }

        if let documentType = params["document.type"] as? String,
            let id = Int(documentType) {
            if let document = bulletimService.getDocuments().first(where: {$0.id == id}) {
                self.documentType = "\(document.name)"
                self.documentValue = params["document.value"] as? String
            }
        }

        let service = (params["service"] as? String) ?? "physical"
        if service.elementsEqual("physical") {
            name = params["name"] as? String
        } else if service.elementsEqual("legal") {
            nomeFantasia = params["name"] as? String
        } else if service.elementsEqual("national") {
            nationalCode = params["nationalCode"] as? String
        } else if service.elementsEqual("state") {
            stateCode = params["stateCode"] as? String
        }
    }

    func getInfos() -> [String: String] {
        var infos = [String: String]()
        setCompanyinfo(&infos)
        setObjectsInfo(&infos)
        setPersonInfo(&infos)
        if let state = state, !state.isEmpty { infos["Estado"] = state }
        if let nationalCode = nationalCode, !nationalCode.isEmpty { infos["Cod. Nacional"] = nationalCode }
        if let stateCode = stateCode, !stateCode.isEmpty { infos["Cod. Estadual"] = stateCode }
        if let city = city, !city.isEmpty { infos["Cidade"] = city }
        return infos
    }

    func set(value: String?, path: ReferenceWritableKeyPath<OccurrenceBulletinFilterViewModel, String?>) {
        self[keyPath: path] = value
        let property = path.stringValue
        if path == \.cpf || path == \.cnpj || path == \.ownerCpf || path == \.documentValue {
            params[property] = value?.onlyNumbers()
        } else if path == \.birthDate {
            params[property] = value?.split(separator: "/").reversed().joined(separator: "-")
        } else if path == \.licensePlate {
            params[property] = value?.onlyStandardCharacters()
        } else {
            params[property] = value
        }
        if let value = value {
            if value.isEmpty {
                params[property] = nil
            }
        }
    }

    func queryParams() throws -> [String: Any] {
        let validator = FormValidator()
        try validator.checkCPFAndCnpjInput(string: cpf)
        try validator.checkCPFAndCnpjInput(string: ownerCpf)
        try validator.checkCPFAndCnpjInput(string: cnpj)
        try validator.checkCPFAndCnpjInput(string: ownerCpf)
        try validator.checkPlate(string: licensePlate)
        try validator.checkDate(string: birthDate)
        try validator.checkChassis(string: chassis)
        var count = params.count
        var hasStateOrCity = false
        if params["bulletin.state"] != nil {
            hasStateOrCity = true
            count = count - 1
        }
        if params["bulletin.city"] != nil {
            hasStateOrCity = true
            count = count - 1
        }
        if count == 0 && hasStateOrCity {
            let error = ApplicationErrors.cityAndStateOnly
            throw NSError(domain: error.message, code: error.code, userInfo: [:])
        }
        return params
    }
}

extension ReferenceWritableKeyPath where Root == OccurrenceBulletinFilterViewModel {
    var stringValue: String {
        switch self {
        case \OccurrenceBulletinFilterViewModel.cnpj: return "cnpj"
        case \OccurrenceBulletinFilterViewModel.nomeFantasia: return "name"
        case \OccurrenceBulletinFilterViewModel.name: return "name"
        case \OccurrenceBulletinFilterViewModel.cpf: return "cpf"
        case \OccurrenceBulletinFilterViewModel.motherName: return "motherName"
        case \OccurrenceBulletinFilterViewModel.fatherName: return "fatherName"
        case \OccurrenceBulletinFilterViewModel.birthDate: return "birthDate"
        case \OccurrenceBulletinFilterViewModel.licensePlate: return "plate"
        case \OccurrenceBulletinFilterViewModel.chassis: return "chassis"
        case \OccurrenceBulletinFilterViewModel.owner: return "owner.name"
        case \OccurrenceBulletinFilterViewModel.possessor: return "possessor.name"
        case \OccurrenceBulletinFilterViewModel.serialNumber: return "serialNumber"
        case \OccurrenceBulletinFilterViewModel.imei: return "imei"
        case \OccurrenceBulletinFilterViewModel.state: return "bulletin.state"
        case \OccurrenceBulletinFilterViewModel.nationalCode: return "nationalCode"
        case \OccurrenceBulletinFilterViewModel.stateCode: return "stateCode"
        case \OccurrenceBulletinFilterViewModel.city: return "bulletin.city"
        case \OccurrenceBulletinFilterViewModel.ownerCpf: return "owner.cpf"
        case \OccurrenceBulletinFilterViewModel.documentType: return "document.type"
        case \OccurrenceBulletinFilterViewModel.documentValue: return "document.value"
        default: fatalError("path não encontrado")
        }
    }
}
