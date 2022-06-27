//
//  PrisionViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 13/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class PrisionViewController: GenericViewController {

    init(prision: Prison) {
        let years = prision.time.years ?? 0
        let months = prision.time.months ?? 0
        let days = prision.time.days ?? 0
        let yearsStr = years > 1 ? "Anos" : "Ano"
        let monthsStr = months > 1 ? "Meses" : "Mês"
        let daysStr = days > 1 ? "Dias" : "Dia"
        super.init(data: [
            [
                ItemDetail(title: "Tipo", detail: prision.type, colunms: 1.5),
                ItemDetail(title: "Regime", detail: prision.regime, colunms: 1.5),
                ItemDetail(title: yearsStr, detail: "\(years)", colunms: 1),
                ItemDetail(title: monthsStr, detail: "\(months)", colunms: 1),
                ItemDetail(title: daysStr, detail: "\(days)", colunms: 1)
            ]
        ], title: "Prisão")
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func contentHeight() -> CGFloat {
        return 120
    }
}
