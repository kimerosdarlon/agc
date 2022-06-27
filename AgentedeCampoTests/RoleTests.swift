//
//  RoleTests.swift
//  AgentedeCampoTests
//
//  Created by Ramires Moreira on 27/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import AgenteDeCampoCommon

class RoleTests: QuickSpec {

    override func spec() {
        describe("Roles") {
            context("check if exist") {
                it("should be true") {
                    expect(Roles.agenteBuscaBO).to(equal("RL_AGC_BUSCA_BO"))
                    expect(Roles.nofityOperationalPause).to(equal("ROLE_AGENTE_CAMPO_NOTIFICAR_PAUSA_OPERACIONAL"))
                    expect(Roles.notifyOcurrency).to(equal("ROLE_AGENTE_CAMPO_NOTIFICAR_OCORRENCIA"))
                    expect(Roles.notifyOcurrencyUpdate).to(equal("ROLE_AGENTE_CAMPO_NOTIFICAR_OCORRENCIA_ATUALIZACAO"))
                    expect(Roles.searchBNMP).to(equal("RL_AGC_BUSCA_BNMP"))
                    expect(Roles.searchVehicle).to(equal("RL_AGC_BUSCA_VEICULO"))
                    expect(Roles.vehicleTrack).to(equal("RL_AGC_BUSCA_VEICULO_RASTRO"))
                    expect(Roles.visualizarEnderecosEnvolvidos).to(equal("RL_AGC_BO_ENVOLVIDO_ENDERECO"))
                    expect(Roles.visualizarEnvolvidos).to(equal("RL_AGC_BO_SAI_VISUALIZAR"))
                    expect(Roles.visualizarRelato).to(equal("RL_AGC_BO_RELATO_VISUALIZAR"))
                }
            }
        }
    }
}
