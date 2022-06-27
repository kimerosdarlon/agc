//
//  OcurrenceBulletinViewControllerTest.swift
//  OcurrencyBulletinUnitTests
//
//  Created by Ramires Moreira on 20/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import OcurrencyBulletin
@testable import AgenteDeCampoCommon

class OcurrenceBulletinFilterTest: QuickSpec {

    override func spec() {
        context("Test filter fill") {
            itShouldClearTextFieldsWhenClearButtonIsPressed()
            itShouldFillAndClearGeneralFilter()
            itShouldFillAndClearObjectVehicleFilter()
            itShouldFillAndClearObjectWeaponFilter()
            itShouldFillAndClearObjectCellphoneFilter()
            itShouldFillPhisicalInvolvedFilter()
            itShouldFillLegalInvolvedFilter()
        }
    }

    func itShouldFillPhisicalInvolvedFilter() {
        it("Should Fill Phisical Involved Filter") {
            let name = "Pedro Silva", cpf = "88583268061", motherName = "Ana Maria",
            fatherName = "Carlos Freitas", birthDate = "1991-05-03", documentValue = "08291429000197",
            documentType = "23"
            let params = [
                "service": ServiceType.physical.rawValue, "name": name,
                "cpf": cpf, "motherName": motherName, "fatherName": fatherName,
                "birthDate": birthDate, "document.type": documentType, "document.value": documentValue,
                "bulletin.state": "CE", "bulletin.city": "2304400"
            ]
            let bulletinController = OcurrenceBulletinViewController(search: params, userInfo: [:], isFromSearch: false)
            let filterController = OccurrenceBulletinFilterViewController(params: params)
            bulletinController.viewDidLoad()
            let mock = BulletinDocumentServiceMock()
            bulletinController.bulletimService = mock
            bulletinController.didClickOnFilterButton(filterController)
            let involved = filterController.involvedFilter
            involved.bulletimService = mock
            involved.viewDidLoad()
            expect(involved.nameTF.textField.text).to(equal(name))
            expect(involved.cpfTF.textField.text).to(equal(cpf.applyCpfORCnpjMask))
            expect(involved.motherNamefTF.textField.text).to(equal(motherName))
            expect(involved.fatherNamefTF.textField.text).to(equal(fatherName))
            expect(involved.birthDatefTF.textField.text).to(equal("03/05/1991"))
            expect(involved.documentValueTF.textField.text).to(equal(documentValue.applyCpfORCnpjMask))
            expect(involved.stateTF.textField.text).to(equal("Ceará"))
            expect(involved.cityTF.textField.text).to(equal("Fortaleza"))
            expect(involved.typeOptions.selectedSegmentIndex).to(equal(0))
            expect(involved.leftButtonText()).to(equal("Limpar (9)"))
        }
    }

    func itShouldFillLegalInvolvedFilter() {
        it("Should Fill Legal Involved Filter") {
            let companyName = "Banco do Brasil", cnpj = "08291429000197"
            let params = [
                "service": ServiceType.legal.rawValue,
                "name": companyName, "cnpj": cnpj, "bulletin.state": "CE", "bulletin.city": "2304400"
            ]
            let bulletinController = OcurrenceBulletinViewController(search: params, userInfo: [:], isFromSearch: false)
            let mock = BulletinDocumentServiceMock()
            bulletinController.bulletimService = mock
            let filterController = OccurrenceBulletinFilterViewController(params: params)
            bulletinController.viewDidLoad()
            bulletinController.didClickOnFilterButton(filterController)
            let involved = filterController.involvedFilter
            involved.viewDidLoad()
            expect(involved.stateTF.textField.text).to(equal("Ceará"))
            expect(involved.cnpjTF.textField.text).to(equal(cnpj.applyCpfORCnpjMask))
            expect(involved.cityTF.textField.text).to(equal("Fortaleza"))
            expect(involved.typeOptions.selectedSegmentIndex).to(equal(1))
            expect(involved.nomeFantasiaTF.textField.text).to(equal(companyName))
            expect(involved.leftButtonText()).to(equal("Limpar (4)"))
        }
    }

    func itShouldClearTextFieldsWhenClearButtonIsPressed() {
        it("Should Clear TextFields When Clear Button Is Pressed") {
            let name = "Pedro Silva", cpf = "88583268061", cnpj = "08291429000197", motherName = "Ana Maria",
            fatherName = "Carlos Freitas", birthDate = "1991-05-03", documentValue = "08291429000197",
            documentType = "23"
            let paramas = [
                "service": ServiceType.physical.rawValue, "name": name,
                "cpf": cpf, "cnpj": cnpj, "motherName": motherName, "fatherName": fatherName,
                "birthDate": birthDate, "document.type": documentType, "document.value": documentValue,
                "bulletin.state": "CE", "bulletin.city": "2304400"
            ]
            let bulletinController = OcurrenceBulletinViewController(search: paramas, userInfo: [:], isFromSearch: false)
            let filterController = OccurrenceBulletinFilterViewController(params: paramas)
            bulletinController.viewDidLoad()
            let mock = BulletinDocumentServiceMock()
            bulletinController.bulletimService = mock
            bulletinController.didClickOnFilterButton(filterController)
            let involved = filterController.involvedFilter
            involved.viewDidLoad()
            involved.didClickOnLeftButton()
            expect(involved.nameTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.cpfTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.cnpjTF.textField.text?.isEmpty).to(equal(false))
            expect(involved.motherNamefTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.fatherNamefTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.birthDatefTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.documentValueTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.documentTypeTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.stateTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.cityTF.textField.text?.isEmpty).to(equal(true))
            expect(involved.selectadeState).to(beNil())
            expect(involved.selectadeCity).to(beNil())
            expect(involved.selectedDocument).to(beNil())
            expect(involved.leftButtonText()).to(equal("Limpar"))
        }
    }

    func itShouldFillAndClearGeneralFilter() {
        let nationalCode = "29773191-00/2019/4106902", state = "CE", stateCode = "20190518946"
        let params = [ "nationalCode": nationalCode, "stateCode": stateCode, "bulletin.state": state ]
        let controller = OcurrenceBulletinViewController(search: params, userInfo: [:], isFromSearch: false)
        let mock = BulletinDocumentServiceMock()
        controller.bulletimService = mock
        let filterController = OccurrenceBulletinFilterViewController(params: params)
        filterController.stateDataSource = StateDataSourceMock()
        controller.viewDidLoad()
        let nationalFilter = filterController.nationalFilter
        it("Should Fill General Filter") {
            controller.didClickOnFilterButton(filterController)
            nationalFilter.viewDidLoad()
            expect(nationalFilter.nationalCodeTF.textField.text).to(equal(nationalCode))
            expect(nationalFilter.stateCodeTF.textField.text).to(equal(stateCode))
            expect(nationalFilter.stateTF.textField.text).to(equal("CE"))
            expect(nationalFilter.leftButtonText()).to(equal("Limpar (3)"))
        }

        it("Should clear GeneralFilter TextFields") {
            nationalFilter.didClickOnLeftButton()
            expect(nationalFilter.nationalCodeTF.textField.text?.isEmpty).to(equal(true))
            expect(nationalFilter.stateCodeTF.textField.text?.isEmpty).to(equal(true))
            expect(nationalFilter.stateTF.textField.text?.isEmpty).to(equal(true))
            expect(nationalFilter.selectadeState).to(beNil())
            expect(nationalFilter.leftButtonText()).to(equal("Limpar"))
        }
    }

    func itShouldFillAndClearObjectVehicleFilter() {
        let plate = "AAA1234", chassi = "5KGXP89G06B160986", owner = "Ana Pereira", possessor = "Luiz Silva"
        let params = [ "plate": plate, "chassis": chassi, "owner.name": owner, "possessor.name": possessor,
                       "service": ServiceType.vehicle.rawValue]
        let controller = OcurrenceBulletinViewController(search: params, userInfo: [:], isFromSearch: false)
        let mock = BulletinDocumentServiceMock()
        controller.bulletimService = mock
        let filterController = OccurrenceBulletinFilterViewController(params: params)
        controller.didClickOnFilterButton(filterController)
        let objetFilter = filterController.objectFilter
        objetFilter.viewDidLoad()
        it("Should fill Vehicle Filter") {
            expect(objetFilter.plateTF.textField.text).to(equal(plate.applyCpfORCnpjMask))
            expect(objetFilter.chassisTF.textField.text).to(equal(chassi))
            expect(objetFilter.ownerTF.textField.text).to(equal(owner))
            expect(objetFilter.possessorfTF.textField.text).to(equal(possessor))
            expect(objetFilter.typeOptions.selectedSegmentIndex).to(equal(0))
            expect(objetFilter.leftButtonText()).to(equal("Limpar (4)"))
        }
        it("Should clear Vehicle Filter") {
            objetFilter.didClickOnLeftButton()
            expect(objetFilter.plateTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.chassisTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.ownerTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.possessorfTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.leftButtonText()).to(equal("Limpar"))
        }
    }

    func itShouldFillAndClearObjectWeaponFilter() {
        let serialNumber = "94119BG234", owner = "Ana Pereira", cpf = "88583268061"
        let params = [ "serialNumber": serialNumber,
                       "owner.name": owner,
                       "service": ServiceType.weapons.rawValue,
                       "owner.cpf": cpf,
                        "bulletin.state": "CE",
                        "bulletin.city": "2304400"
        ]
        let controller = OcurrenceBulletinViewController(search: params, userInfo: [:], isFromSearch: false)
        let mock = BulletinDocumentServiceMock()
        controller.bulletimService = mock
        let filterController = OccurrenceBulletinFilterViewController(params: params)
        filterController.stateDataSource = StateDataSourceMock()
        let objetFilter = filterController.objectFilter
        it("Should fill Weapon filter") {
            controller.didClickOnFilterButton(filterController)
            objetFilter.viewDidLoad()
            expect(objetFilter.serialNumberTF.textField.text).to(equal(serialNumber))
            expect(objetFilter.ownerTF.textField.text).to(equal(owner))
            expect(objetFilter.ownerCpfTF.textField.text).to(equal(cpf.applyCpfORCnpjMask))
            expect(objetFilter.stateTF.textField.text).to(equal("Ceará"))
            expect(objetFilter.cityTF.textField.text).to(equal("Fortaleza"))
            expect(objetFilter.typeOptions.selectedSegmentIndex).to(equal(1))
            expect(objetFilter.leftButtonText()).to(equal("Limpar (5)"))
        }
        it("Should clear Weapon Filter") {
            objetFilter.didClickOnLeftButton()
            expect(objetFilter.serialNumberTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.stateTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.cityTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.ownerCpfTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.ownerTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.selectadeCity).to(beNil())
            expect(objetFilter.selectadeState).to(beNil())
            expect(objetFilter.leftButtonText()).to(equal("Limpar"))
        }
    }

    func itShouldFillAndClearObjectCellphoneFilter() {
        let serialNumber = "94119BG234", imei = "88583268061"
        let params = [ "serialNumber": serialNumber,
                       "imei": imei,
                       "service": ServiceType.cellphones.rawValue,
                       "bulletin.state": "CE",
                       "bulletin.city": "2304400"
        ]
        let controller = OcurrenceBulletinViewController(search: params, userInfo: [:], isFromSearch: false)
        let mock = BulletinDocumentServiceMock()
        controller.bulletimService = mock
        let filterController = OccurrenceBulletinFilterViewController(params: params)
        controller.didClickOnFilterButton(filterController)
        filterController.stateDataSource = StateDataSourceMock()
        let objetFilter = filterController.objectFilter
        objetFilter.viewDidLoad()
        it("Should fill Cellphone filter") {
            expect(objetFilter.serialNumberTF.textField.text).to(equal(serialNumber))
            expect(objetFilter.imeiTF.textField.text).to(equal(imei))
            expect(objetFilter.stateTF.textField.text).to(equal("Ceará"))
            expect(objetFilter.cityTF.textField.text).to(equal("Fortaleza"))
            expect(objetFilter.typeOptions.selectedSegmentIndex).to(equal(2))
            expect(objetFilter.leftButtonText()).to(equal("Limpar (4)"))
        }
        it("Should clear Cellphone Filter") {
            objetFilter.didClickOnLeftButton()
            expect(objetFilter.serialNumberTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.stateTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.cityTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.imeiTF.textField.text?.isEmpty).to(equal(true))
            expect(objetFilter.selectadeCity).to(beNil())
            expect(objetFilter.selectadeState).to(beNil())
            expect(objetFilter.leftButtonText()).to(equal("Limpar"))
        }
    }
}

class BulletinDocumentServiceMock: BulletimDocumentService {

    func setupDocument(_ delegate: DocumentTypeDataSourceDelegate, withType type: String?) {
        delegate.didSelect(document: DocumentType(document: getDocuments()[0]))
    }

    func getDocuments() -> [APIDocumentType] {
        return [
            APIDocumentType(name: "CNPJ", id: 23)
        ]
    }

    func loadAll(completion: @escaping (Result<[APIDocumentType], Error>) -> Void) {
        completion(.success(getDocuments()))
    }
}

class BulletionControllerMock: NationalCodeBulletinFilterViewController {
    var searchByNationalCodeIsCalled = false
    var searchByStateCodeIsCalled = false

    override func searchBy(stateCode: String, completion: @escaping (Result<BulletinDetails, Error>) -> Void) {
        searchByStateCodeIsCalled = true
        super.searchBy(stateCode: stateCode, completion: completion)
    }

    override func searchBy(nationalCode: String, completion: @escaping (Result<BulletinDetails, Error>) -> Void) {
        searchByNationalCodeIsCalled = true
        super.searchBy(nationalCode: nationalCode, completion: completion)
    }
}
