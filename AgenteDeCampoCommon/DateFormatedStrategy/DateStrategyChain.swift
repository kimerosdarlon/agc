//
//  DateStrategyChain.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 01/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct DateStrategyChain {

    public init() {
    }

    public func getFormatedDateFrom(startDate: Date, endDate: Date) -> String {
        let dateStrategy = DateStratagy()
        let yearStategy = YearStrategy(next: dateStrategy)
        let monthStrategy = MonthStrategy(next: yearStategy)
        let weekStrategy = WeekStrategy(next: monthStrategy)
        let dayStrategy = DayStrategy(next: weekStrategy)
        let hourStrategy = HourStrategy(next: dayStrategy)
        let minuteStrategy = MinuteStrategy(next: hourStrategy)
        return minuteStrategy.getHumanDate(from: startDate, to: endDate)
    }
}
