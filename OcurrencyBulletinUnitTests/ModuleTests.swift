//
//  OcurrencyBulletinUnitTests.swift
//  OcurrencyBulletinUnitTests
//
//  Created by Ramires Moreira on 16/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import XCTest
import Nimble
import Quick
import UIKit
@testable import OcurrencyBulletin
@testable import AgenteDeCampoCommon

class ModuleTests: QuickSpec {

    override func spec() {
        let bulletin = OcurencyBulletinModule()
        describe("Test bulletin regex patterns") {
            runCPFTests(bulletin)
            runCNPJTests(bulletin)
        }

        testModuludeDefinitions(bulletin)

        describe("Test bulletin params for request") {
            itShouldReturnInvolvedParams(bulletin)
            itShouldReturnPlateParams(bulletin)
            itShouldReturnChassiParams(bulletin)
            itShouldReturnNationalCodeParams(bulletin)
            itShouldReturnCPFParams(bulletin)
            itShouldReturnCNPJParmas(bulletin)
            itShouldBeEmptyForSingleName(bulletin)
        }

        describe("Test bulletin infos") {
            itShouldReturnInvolvedInfo(bulletin)
            itShouldReturnPlateInfo(bulletin)
            itShouldReturnNationalCodeInfo(bulletin)
            itShouldReturnChassiInfo(bulletin)
            itShouldReturnCPFInfo(bulletin)
            itShouldReturnCNPJInfo(bulletin)
        }

        describe("Test bulletin actions") {
            it("Should return a search action") {
                let actions = bulletin.getActionsFor(text: "PEDRO FREITAS", exceptedModuleNames: [])
                let image = UIImage(systemName: "magnifyingglass")
                expect(actions.count).to(equal(1))
                expect(actions.first?.title).to(equal("Buscar em Boletins de ocorrência"))
                expect(actions.first?.image).toNot(beNil())
                expect(actions.first?.image).to(equal(image))
            }
            it("Should return empty action") {
                let actions = bulletin.getActionsFor(text: "PEDRO FREITAS", exceptedModuleNames: [bulletin.name])
                expect(actions.isEmpty).to(equal(true))
            }
        }
    }

    private func itShouldReturnCNPJInfo(_ bulletin: OcurencyBulletinModule) {
        it("Should return cnpj info") {
            let params = ["cnpj": "88156475000112", "service": ServiceType.vehicle.rawValue]
            var infos = bulletin.getInfoFor(text: "", query: params)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("CNPJ: 88.156.475/0001-12"))

            infos = bulletin.getInfoFor(text: "88156475000112", query: nil)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("CNPJ: 88.156.475/0001-12"))
        }
    }

    private func itShouldReturnCPFInfo(_ bulletin: OcurencyBulletinModule) {
        it("Should return cpf info") {
            let params = ["cpf": "12417388073", "service": ServiceType.vehicle.rawValue]
            var infos = bulletin.getInfoFor(text: "", query: params)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("CPF: 124.173.880-73"))

            infos = bulletin.getInfoFor(text: "12417388073", query: nil)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("CPF: 124.173.880-73"))
        }
    }

    fileprivate func itShouldReturnPlateInfo(_ bulletin: OcurencyBulletinModule) {
        it("Should return plate info") {
            let params = ["plate": "AAA1234", "service": ServiceType.vehicle.rawValue]
            var infos = bulletin.getInfoFor(text: "", query: params)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("Placa: AAA-1234"))

            infos = bulletin.getInfoFor(text: "AAA1234", query: nil)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("Placa: AAA-1234"))
        }
    }

    fileprivate func itShouldReturnChassiInfo(_ bulletin: OcurencyBulletinModule) {
        it("Should return chassi info") {
            let params = ["chassis": "8CHXH19G90B162390", "service": ServiceType.vehicle.rawValue]
            var infos = bulletin.getInfoFor(text: "", query: params)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("Chassi: 8CHXH19G90B162390"))

            infos = bulletin.getInfoFor(text: "8CHXH19G90B162390", query: nil)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("Chassi: 8CHXH19G90B162390"))
        }
    }

    fileprivate func itShouldReturnNationalCodeInfo(_ bulletin: OcurencyBulletinModule) {
        it("Should return national code info") {
            let params = ["nationalCode": "29773191-00/2019/4106902", "service": ServiceType.national.rawValue]
            var infos = bulletin.getInfoFor(text: "", query: params)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("Cod. Nacional: 29773191-00/2019/4106902"))

            infos = bulletin.getInfoFor(text: "29773191-00/2019/4106902", query: nil)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("Cod. Nacional: 29773191-00/2019/4106902"))
        }
    }

    fileprivate func itShouldReturnInvolvedInfo(_ bulletin: OcurencyBulletinModule) {
        it("Should return involved info") {
            let params = ["name": "JOAO DA SILVA", "service": ServiceType.physical.rawValue]
            var infos = bulletin.getInfoFor(text: "", query: params)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("Nome: JOAO DA SILVA"))

            infos = bulletin.getInfoFor(text: "JOAO DA SILVA", query: nil)
            expect(infos.count).to(equal(1))
            expect(infos.toString).to(equal("Nome: JOAO DA SILVA"))
        }
    }

    fileprivate func itShouldBeEmptyForSingleName(_ bulletin: OcurencyBulletinModule) {
        it("should be empty for single name") {
            let someString = "JOAO"
            let params = bulletin.getParamsFor(text: someString) as! [String: String]
            expect(params.isEmpty).to(equal(true))
        }
    }

    fileprivate func itShouldReturnCNPJParmas(_ bulletin: OcurencyBulletinModule) {
        it("check cnpj params") {
            let cnpj = "65.934.384/0001-65"
            let params = bulletin.getParamsFor(text: cnpj) as! [String: String]
            expect(params.count).to(equal(2))
            expect(params["service"]).to(equal(ServiceType.legal.rawValue))
            expect(params["cnpj"]).to(equal("65934384000165"))
        }
    }

    fileprivate func itShouldReturnCPFParams(_ bulletin: OcurencyBulletinModule) {
        it("check cpf params") {
            let cpf = "124.173.880-73"
            let params = bulletin.getParamsFor(text: cpf) as! [String: String]
            expect(params.count).to(equal(2))
            expect(params["service"]).to(equal(ServiceType.physical.rawValue))
            expect(params["cpf"]).to(equal("12417388073"))
        }
    }

    fileprivate func itShouldReturnNationalCodeParams(_ bulletin: OcurencyBulletinModule) {
        it("check national code params") {
            let nationalCode = "29773191-00/2019/4106902"
            let params = bulletin.getParamsFor(text: nationalCode) as! [String: String]
            expect(params.count).to(equal(2))
            expect(params["service"]).to(equal(ServiceType.national.rawValue))
            expect(params["nationalCode"]).to(equal(nationalCode))
        }
    }

    fileprivate func itShouldReturnChassiParams(_ bulletin: OcurencyBulletinModule) {
        it("check chassi params") {
            let chassi = "8CHXH19G90B162390"
            let params = bulletin.getParamsFor(text: chassi) as! [String: String]
            expect(params.count).to(equal(2))
            expect(params["service"]).to(equal(ServiceType.vehicle.rawValue))
            expect(params["chassis"]).to(equal(chassi))
        }
    }

    fileprivate func itShouldReturnPlateParams(_ bulletin: OcurencyBulletinModule) {
        it("check plate params") {
            let plate = "AAA-1234"
            let params = bulletin.getParamsFor(text: plate) as! [String: String]
            expect(params.count).to(equal(2))
            expect(params["service"]).to(equal(ServiceType.vehicle.rawValue))
            expect(params["plate"]).to(equal("AAA1234"))
        }
    }

    fileprivate func itShouldReturnInvolvedParams(_ bulletin: OcurencyBulletinModule) {
        it("check involved request params") {
            let involved = "JOAO DA SILVA"
            let params = bulletin.getParamsFor(text: involved) as! [String: String]
            expect(params.count).to(equal(2))
            expect(params["service"]).to(equal(ServiceType.physical.rawValue))
            expect(params["name"]).to(equal(involved))
        }
    }

    fileprivate func testModuludeDefinitions(_ bulletin: OcurencyBulletinModule) {

        describe("Check module name") {
            it("should be Boletim") {
                expect(bulletin.name).to(equal("Boletins de ocorrência"))
            }
        }

        describe("Check module role") {
            it("Should be ROLE_AGENTE_CAMPO_BUSCA_BO") {
                expect(bulletin.role).to(equal(Roles.agenteBuscaBO))
            }
        }

        describe("Check module controllers") {
            it("shold be OcurrenceBulletinViewController") {
                expect(bulletin.controller.self == OcurrenceBulletinViewController.self )
                    .to(equal(true))
            }
            it("shold be OccurrenceBulletinFilterViewController") {
                expect(bulletin.filterController.self == OccurrenceBulletinFilterViewController.self )
                    .to(equal(true))
            }
        }

        describe("Check if is active") {
            it("should be true") {
                expect(bulletin.isEnable ).to(equal(true))
            }
        }

        describe("Check module icon name") {
            it("should be bulletim") {
                expect(bulletin.imageName).to(equal("bulletin"))
            }
        }
    }

    fileprivate func runCPFTests(_ bulletin: OcurencyBulletinModule) {
        context("should match with") {
            it("CPF with symbols") {
                expect(bulletin.matches(in: "829.620.710-90")).to(equal(true))
            }
            it("CPF without symbols") {
                expect(bulletin.matches(in: "82962071090")).to(equal(true))
            }
        }

        context("should not match with") {
            it("imcomplet CPF") {
                expect(bulletin.matches(in: "829.620.710-9")).to(equal(false))
                expect(bulletin.matches(in: "8296207109")).to(equal(false))
            }
            it("letters in CPF") {
                expect(bulletin.matches(in: "8a9.620.710-90")).to(equal(false))
                expect(bulletin.matches(in: "8296207109CP")).to(equal(false))
            }
        }
    }

    fileprivate func runCNPJTests(_ bulletin: OcurencyBulletinModule) {
        context("should match with") {
            it("CNPJ with symbols") {
                expect(bulletin.matches(in: "88.156.475/0001-12")).to(equal(true))
            }
            it("CNPJ without symbols") {
                expect(bulletin.matches(in: "88156475000112")).to(equal(true))
            }
        }
    }
}
