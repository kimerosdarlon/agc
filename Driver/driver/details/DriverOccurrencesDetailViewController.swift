//
//  DriverOccurrencesDetailViewController.swift
//  Driver
//
//  Created by Samir Chaves on 16/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation

import AgenteDeCampoCommon
import AgenteDeCampoModule
import SPAlert
import UIKit

class DriverOccurrencesDetailViewController: DriverDetailPageViewController {
    private var occurrences = [Occurrence]()

    init(with driverOccurrences: [Occurrence]) {
        super.init()
        occurrences = driverOccurrences
        title = "Ocorrências"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func formatDate(_ date: String) -> String {
        date.split(separator: "-").reversed().joined(separator: "/")
    }

    private func buildOccurrenceCard(details: Occurrence, identifier: String) -> DetailsBlock {
        let generalGroup = DetailsGroup(
            items: [
                [(title: "Descrição", detail: details.description.fillEmpty())],
                [(title: "Documento Gerador", detail: details.document.fillEmpty()), (title: "UF DETRAN", detail: details.uf.fillEmpty())],
                [(title: "Data Início", detail: formatDate(details.start).fillEmpty()), (title: "Data Fim", detail: formatDate(details.end).fillEmpty())]
            ]
        )

        let lockingGroup = DetailsGroup(
            items: [
                [(title: "Decisão", detail: details.decision.fillEmpty())],
                [(title: "Requisitos de Liberação", detail: (details.liberation ?? "").fillEmpty())],
                [(title: "Prazo Penal", detail: details.deadline.fillEmpty())],
                [(title: "Prazo Total", detail: details.totalDeadline.fillEmpty())]
            ],
            withHeader: "Bloqueio"
        )

        return DetailsBlock(groups: [
            generalGroup,
            lockingGroup
        ], identifier: identifier)
    }

    override func viewDidLoad() {

        if occurrences.count == 0 {
            let notFoundMessage = UILabel(frame: .zero)
            notFoundMessage.text = "Nenhuma ocorrência registrada."
            notFoundMessage.textAlignment = .center
            notFoundMessage.textColor = .appCellLabel
            notFoundMessage.enableAutoLayout()
            notFoundMessage.alpha = 0.6
            view.addSubview(notFoundMessage)

            NSLayoutConstraint.activate([
                notFoundMessage.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                notFoundMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            view.addSubview(scrollContainer)
            scrollContainer.width(view)

            let listBuilder = ListBasedDetailBuilder(into: scrollContainer)

            listBuilder.buildDetailsBlocks(occurrences.enumerated().map { index, occurrence in
                buildOccurrenceCard(details: occurrence, identifier: "\(index)")
            })

            NSLayoutConstraint.activate([
                scrollContainer.topAnchor.constraint(equalTo: view.topAnchor),
                view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollContainer.bottomAnchor, multiplier: 1)
            ])
            listBuilder.setupLayout()
        }
    }
}
