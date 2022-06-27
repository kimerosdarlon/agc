//
//  ACEnviromentTest.swift
//  AgentedeCampoTests
//
//  Created by Ramires Moreira on 23/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import AgenteDeCampoCommon
class ACEnviromentTest: QuickSpec {

    override func spec() {
        describe("ACEnviroment") {
            context("check if exist") {
                it("should be true") {
                    expect(ACEnviroment.shared.host.isEmpty).to(equal(false))
                    expect(ACEnviroment.shared.logApppId.isEmpty).to(equal(false))
                    expect(ACEnviroment.shared.logAppSecret.isEmpty).to(equal(false))
                    expect(ACEnviroment.shared.logEncryptionKey.isEmpty).to(equal(false))
                }
            }
        }
    }
}
