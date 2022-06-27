//
//  VehicleAlertViewModel.swift
//  Vehicle
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import AgenteDeCampoCommon

struct VehicleAlertViewModel {
    let alert: VehicleAlert

    init(alert: VehicleAlert) {
        self.alert = alert
    }

    var date: String {
        return alert.dateFormatted
    }

    var headerDate: String {
        let chain = DateStrategyChain()
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: alert.occurrenceDate) else {
            return alert.dateFormatted
        }
        return chain.getFormatedDateFrom(startDate: date, endDate: today)
    }

    var headerTitle: String {
        return alert.type
    }

    var headerSource: String {
        return "FONTE: \(alert.occurrenceBulletin?.system ?? "") "
    }

    var pocileStation: String {
        return alert.occurrenceBulletin?.policeStation ?? "---"
    }

    var bulleetimProtocol: String {
        return alert.occurrenceBulletin?.number ?? "---"
    }

    var city: String {
        guard let city = alert.occurrenceBulletin?.city,
            let state = alert.occurrenceBulletin?.state,
            !state.isEmpty, !city.isEmpty else {
                return "---"
        }
        return "\(city)-\(state)"
    }

    var name: String {
        guard let name = alert.contact?.name, !name.isEmpty else {
            return "---"
        }
        return name
    }

    var phone: String {
        guard let phone = alert.contact?.formattedCellFone, !phone.isEmpty else {
            return "---"
        }
        return phone
    }

    var ramal: String {
        return "---"
    }
}
