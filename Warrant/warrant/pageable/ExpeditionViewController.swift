//
//  ExpeditionViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class ExpeditionViewController: GenericViewController {

    init(expedidtion: Expedition) {
        super.init(data: [[
            ItemDetail(title: "Motivo", detail: expedidtion.reason, colunms: 1.5),
            ItemDetail(title: "Data", detail: expedidtion.dateFormatted, colunms: 1.5),
            ItemDetail(title: "Motivo da licença", detail: expedidtion.licenseReason, colunms: 1.5),
            ItemDetail(title: "Orgão", detail: expedidtion.organ.name, colunms: 1.5),
            ItemDetail(title: "Cidade/UF", detail: "\(expedidtion.organ.city)/\(expedidtion.organ.state)", colunms: 1.5)
        ]], title: "Expedição")
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func contentHeight() -> CGFloat {
        return 160
    }

}
