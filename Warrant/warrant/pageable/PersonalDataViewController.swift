//
//  PersonalDataViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
class PersonalDataViewController: GenericViewController {

    init(personalData: Personal) {
        super.init(data: [
            [
                ItemDetail(title: "Sexo", detail: personalData.gender, colunms: 1.5),
                ItemDetail(title: "Data de nascimento", detail: personalData.birthDateFormatted, colunms: 1.5),
                ItemDetail(title: "Nacionalidade", detail: personalData.nationality, colunms: 1.5),
                ItemDetail(title: "Nome da mãe", detail: personalData.motherName, colunms: 3),
                ItemDetail(title: "Nome do pai", detail: personalData.fatherName, colunms: 3)
            ]
        ], title: "Dados Pessoais")
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
