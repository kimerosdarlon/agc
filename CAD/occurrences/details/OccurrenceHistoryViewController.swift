//
//  OccurrenceHistoryViewController.swift
//  CAD
//
//  Created by Samir Chaves on 21/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class OccurrenceHistoryViewController: UIViewController {
    private var occurrence: OccurrenceDetails!
    private lazy var detailsContainer = ListBasedDetailTableView(padding: .init(top: 15, left: 15, bottom: 0, right: 15)).enableAutoLayout()

    init(details: OccurrenceDetails) {
        super.init(nibName: nil, bundle: nil)
        occurrence = details
        title = "Histórico"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    private let header = OccurrencePropertyView(title: "Histórico", descriptionView: nil, iconName: "note")

    private func fillEmpty(_ text: String?) -> String {
        text?.fillEmpty() ?? String.emptyProperty
    }

    private func getHistoryBlocks() -> [DetailsBlock] {
        return occurrence.history.map { historyItem -> DetailsBlock in
            let timeZone = occurrence.generalInfo.occurrenceRegisteredAt.timeZone
            var dateTime = historyItem.dateTime
                    .toDate(format: "yyyy-MM-dd'T'HH-mm-ss")?
                    .fromUTCTo(timeZone)
                    .format(to: "dd/MM/yyyy HH:mm:ss")
            dateTime = dateTime.map { s in "\(s) \(timeZone)" }
            return DetailsBlock(
                group: DetailsGroup(items: [
                    [
                        (title: "Operador", detail: fillEmpty(historyItem.owner?.name)),
                        (title: "Data", detail: fillEmpty(dateTime))
                    ],
                    [(title: "Tipo", detail: fillEmpty(historyItem.eventType))],
                    [(title: "Texto", detail: fillEmpty(historyItem.eventDescription))]
                ]),
                identifier: "history"
            )
        }
    }

    override func viewDidLoad() {
        view.addSubview(detailsContainer)

        detailsContainer.delaysContentTouches = true
        detailsContainer.canCancelContentTouches = false

        if occurrence.history.isEmpty {
            let notFoundLabel = UILabel.build(withSize: 14, alpha: 0.8, color: .appTitle, alignment: .center, text: "Nenhum histórico presente nesta ocorrência.").enableAutoLayout()
            view.addSubview(notFoundLabel)
            notFoundLabel.width(view).height(50).centerX().top(view, mutiplier: 1)
        }

        detailsContainer.height(400)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            detailsContainer.topAnchor.constraint(equalTo: safeArea.topAnchor),
            detailsContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            detailsContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: detailsContainer.bottomAnchor, multiplier: 1)
        ])

        let historyBlocks = getHistoryBlocks()
        detailsContainer.apply(blocks: historyBlocks)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserStylePreferences.theme.style == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .systemGray5
        }
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}
