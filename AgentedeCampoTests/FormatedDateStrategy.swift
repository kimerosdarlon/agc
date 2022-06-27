//
//  FormatedDateStrategy.swift
//  AgentedeCampoTests
//
//  Created by Ramires Moreira on 11/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import AgenteDeCampoCommon

class FormatedDateStrategyTest: QuickSpec {

    var dateFormated: DateFormatter {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formater
    }

    override func spec() {
        describe("Formatacao de data") {
            self.runMinuteTest()
            self.runHourTest()
            self.runDayTest()
            self.runMonthTest()
            self.runWeekTest()
            self.runYearTest()
        }
    }

    func runMinuteTest() {
        context("Strategia de minutos") {
            let strDateFrom = "2020-06-06T11:10:00"
            let dateFrom = self.dateFormated.date(from: strDateFrom)!
            let strDateTo = "2020-06-06T12:00:00"
            let dateTo = self.dateFormated.date(from: strDateTo)!
            let minuteStrategy = MinuteStrategy()
            it("Deve retornar minutos no plural") {
                let result = minuteStrategy.getHumanDate(from: dateFrom, to: dateTo)
                expect(result).to(equal("Há 50 minutos"))
            }

            it("Deve retornar minutos singular") {
                let strDateFrom = "2020-06-06T11:59:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-06T12:00:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!

                let result = minuteStrategy.getHumanDate(from: dateFrom, to: dateTo)
                expect(result).to(equal("Há 1 minuto"))
            }
        }
    }

    func runHourTest() {
        context("Strategia de hora") {
            let hourStrategy = HourStrategy()
            it("Deve retornar hora no singular") {
                let strDateFrom = "2020-06-06T11:59:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-06T13:40:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = hourStrategy.getHumanDate(from: dateFrom, to: dateTo)
                expect(result).to(equal("Há 1 hora"))
            }

            it("Deve retornar horas no plural") {
                let strDateFrom = "2020-06-06T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-06T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = hourStrategy.getHumanDate(from: dateFrom, to: dateTo)
                expect(result).to(equal("Há 3 horas"))
            }
        }
    }

    func runDayTest() {
        context("Strategia de dia") {
            let dayStrategy = DayStrategy()
            it("Deve retornar dia no singular") {
                let strDateFrom = "2020-06-06T11:59:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-07T13:40:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = dayStrategy.getHumanDate(from: dateFrom, to: dateTo)
                expect(result).to(equal("Há 1 dia"))
            }

            it("Deve retornar dias no plural") {
                let strDateFrom = "2020-06-06T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-10T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = dayStrategy.getHumanDate(from: dateFrom, to: dateTo)
                expect(result).to(equal("Há 4 dias"))
            }
        }
    }

    func runWeekTest() {
        context("Strategy Chain") {
            it("Deve retornar semana no singular") {
                let chain = DateStrategyChain()
                let strDateFrom = "2020-06-01T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-09T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = chain.getFormatedDateFrom(startDate: dateFrom, endDate: dateTo)
                expect(result).to(equal("Há 1 semana"))
            }

            it("Deve retornar semanas no plural") {
                let chain = DateStrategyChain()
                let strDateFrom = "2020-06-01T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-16T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = chain.getFormatedDateFrom(startDate: dateFrom, endDate: dateTo)
                expect(result).to(equal("Há 2 semanas"))
            }
        }
    }

    func runMonthTest() {
        context("Strategy Chain") {
            it("Deve retornar mês no singular") {
                let chain = DateStrategyChain()
                let strDateFrom = "2020-05-06T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-10T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = chain.getFormatedDateFrom(startDate: dateFrom, endDate: dateTo)
                expect(result).to(equal("Há 1 mês"))
            }

            it("Deve retornar meses no plural") {
                let chain = DateStrategyChain()
                let strDateFrom = "2020-04-06T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-10T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = chain.getFormatedDateFrom(startDate: dateFrom, endDate: dateTo)
                expect(result).to(equal("Há 2 meses"))
            }
        }
    }

    func runYearTest() {
        context("Strategy Chain") {
            it("Deve retornar ano no singular") {
                let chain = DateStrategyChain()
                let strDateFrom = "2019-05-06T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-05-10T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = chain.getFormatedDateFrom(startDate: dateFrom, endDate: dateTo)
                expect(result).to(equal("Há 1 ano"))
            }

            it("Deve retornar anos no plural") {
                let chain = DateStrategyChain()
                let strDateFrom = "2015-04-06T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-04-10T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = chain.getFormatedDateFrom(startDate: dateFrom, endDate: dateTo)
                expect(result).to(equal("Há 5 anos"))
            }

            it("Deve retornar ha mais de x anos") {
                let chain = DateStrategyChain()
                let strDateFrom = "2015-04-06T13:00:00"
                let dateFrom =  self.dateFormated.date(from: strDateFrom)!
                let strDateTo = "2020-06-10T16:20:00"
                let dateTo = self.dateFormated.date(from: strDateTo)!
                let result = chain.getFormatedDateFrom(startDate: dateFrom, endDate: dateTo)
                expect(result).to(equal("Há mais de 5 anos"))
            }
        }
    }
}
