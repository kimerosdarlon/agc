//
//  DriverIndividualDetailViewController.swift
//  Driver
//
//  Created by Samir Chaves on 16/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import AgenteDeCampoModule
import UIKit

class DriverIndividualDetailViewController: DriverDetailPageViewController {
    private var detail: Individual!
    private let dateFormatter = DateFormatter()
    private var listBuilder: ListBasedDetailBuilder!

    init(with individualDriverDetail: Individual) {
        super.init()
        detail = individualDriverDetail
        title = "Dados Pessoais"
        dateFormatter.dateFormat = "dd/MM/yyyy"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fillBlankField(_ value: String?) -> String {
        value == nil || value! == "" || value! == "INEXISTENTE" ? "————" : value!
    }

    private func formatDate(_ dateOpt: Date?) -> String {
        if let date = dateOpt {
            return dateFormatter.string(from: date)
        }

        return "————"
    }

    private func getCPFBlock() -> DetailsGroup {
        let regex = "(\\d{3})(\\d{3})(\\d{3})(\\d{2})"
        let repl = "$1.$2.$3-$4"
        let formattedCpf = detail.cpf.replacingOccurrences(of: regex, with: repl, options: [.regularExpression])
        return DetailsGroup(items: [
            [InteractableDetailItem(fromItem: (title: "CPF", detail: formattedCpf), exceptedModulesInInteraction: ["Condutores"])]
        ])
    }

    private func getDetailsBlock() -> DetailsGroup {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let birthDate = formatter.date(from: detail.birth.date)
        return DetailsGroup(items: [
            [
                (title: detail.document.description, detail: detail.document.number.fillEmpty()),
                (title: "ORGÃO EMISSOR/UF", detail: "\(detail.document.organization.fillEmpty())/\(detail.document.uf.fillEmpty())")
            ],
            [(title: "Nascimento", detail: detail.birth.place.fillEmpty()), (title: "Data de Nascimento", detail: formatDate(birthDate))],
            [(title: "Nacionalidade", detail: detail.nationality.fillEmpty())]
        ])
    }

    private func getParentsBlock() -> DetailsGroup {
        return DetailsGroup(items: [
            [InteractableDetailItem(fromItem: (title: "Nome da Mãe", detail: detail.mother.fillEmpty()))],
            [InteractableDetailItem(fromItem: (title: "Nome do Pai", detail: detail.father.fillEmpty()))]
        ])
    }

    private func getAddressBlock() -> DetailsGroup {
        DetailsGroup(
            items: [
                [(title: "Logradouro", detail: fillBlankField(detail.address?.place)), (title: "Número", detail: fillBlankField(detail.address?.number))],
                [(title: "Complemento", detail: fillBlankField(detail.address?.complement)), (title: "CEP", detail: fillBlankField(detail.address?.cep))],
                [(title: "UF", detail: fillBlankField(detail.address?.uf)), (title: "Município", detail: fillBlankField(detail.address?.city))],
                [(title: "Bairro", detail: fillBlankField(detail.address?.district))]
            ],
            withHeader: "Endereço"
        )
    }

    override func viewDidLoad() {
        view.addSubview(scrollContainer)
        listBuilder = ListBasedDetailBuilder(into: scrollContainer)

        listBuilder.buildDetailsBlock(
            DetailsBlock(groups: [
                getCPFBlock(),
                getDetailsBlock(),
                getParentsBlock(),
                getAddressBlock()
            ], identifier: "general")
        )
        scrollContainer.width(view)
//        scrollContainer.isUserInteractionEnabled = true
//        scrollContainer.isExclusiveTouch = true
//        scrollContainer.delaysContentTouches = true
//        scrollContainer.canCancelContentTouches = false

        NSLayoutConstraint.activate([
            scrollContainer.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollContainer.bottomAnchor, multiplier: 1)
        ])
        listBuilder.setupLayout()
    }
}
