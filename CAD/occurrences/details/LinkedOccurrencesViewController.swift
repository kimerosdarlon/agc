//
//  LinkedOccurrencesViewController.swift
//  CAD
//
//  Created by Samir Chaves on 01/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import SPAlert

private class OccurrenceCardHeader: UIView {
    private let occurrence: ComplementaryOccurrence
    private let mainOccurrence: OccurrenceDetails
    private let priorityLabel: OccurrencePriorityLabel
    private let titleLabel = UILabel.build(withSize: 15, weight: .bold)

    init(occurrence: ComplementaryOccurrence, mainOccurrence: OccurrenceDetails) {
        self.occurrence = occurrence
        self.mainOccurrence = mainOccurrence
        self.priorityLabel = OccurrencePriorityLabel().withPriority(occurrence.priority)
        super.init(frame: .zero)
        let title = occurrence.`protocol`
        let interaction = UIContextMenuInteraction(delegate: self)
        interaction.view?.backgroundColor = titleLabel.backgroundColor
        interaction.view?.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        let textRange = NSRange(location: 0, length: title.count)
        let attributedText = NSMutableAttributedString(string: title)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue, range: textRange)
        titleLabel.text = title
        titleLabel.addInteraction(interaction)
        titleLabel.isUserInteractionEnabled = true
        titleLabel.attributedText = attributedText
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        addSubview(titleLabel)
        addSubview(priorityLabel)
        titleLabel.left(self, mutiplier: 0)
        priorityLabel.right(to: self.trailingAnchor, 0)
        height(17)
    }
}

extension OccurrenceCardHeader: UIContextMenuInteractionDelegate {
    private func buildCopyAction(for text: String) -> UIAction {
        let copyImage = UIImage(systemName: "doc.on.doc.fill")
        let copyAction = UIAction(title: "Copiar", image: copyImage) { _  in
            UIPasteboard.general.string = text
            SPAlert.present(title: "Tudo pronto",
                            message: "O texto \(text) foi copiado para a sua área de tranferência",
                            preset: .done)
        }
        return copyAction
    }

    private func createContextMenu() -> UIMenu {
        var actions: [UIAction] = [
            buildCopyAction(for: occurrence.`protocol`)
        ]

        let agency = mainOccurrence.operatingRegion.agency
        let params = [
            "agencyId": ["serviceValue": agency.id, "userValue": agency.name],
            "protocol": ["serviceValue": occurrence.`protocol`, "userValue": occurrence.`protocol`]
        ]
        let controller = OccurrencesViewController(search: params, userInfo: [
            "Agência": "\(agency.initials) - \(agency.name)",
            "Protocolo": occurrence.`protocol`
        ], isFromSearch: false)
        let image = UIImage(systemName: "magnifyingglass")
        let searchAction = UIAction(title: "Buscar em Ocorrências", image: image) { _ in
            garanteeMainThread {
                NotificationCenter.default.post(name: .actionNavigation,
                                                object: nil,
                                                userInfo: ["viewController": controller])
            }
        }
        actions.append(searchAction)
        return UIMenu(title: "Opções", children: actions)
    }

    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
//            let feedback = UISelectionFeedbackGenerator()
//            feedback.prepare()
//            feedback.selectionChanged()
            return self.createContextMenu()
        }
    }
}

class LinkedOccurrencesViewController: UIViewController {

    private var occurrences = [ComplementaryOccurrence]()
    private var mainOccurrence: OccurrenceDetails
    private var emptyFeedback: String
    private var listBuilder: ListBasedDetailBuilder!

    init(with occurrences: [ComplementaryOccurrence], mainOccurrence: OccurrenceDetails, title: String, emptyFeedback: String) {
        self.emptyFeedback = emptyFeedback
        self.mainOccurrence = mainOccurrence
        super.init(nibName: nil, bundle: nil)
        self.occurrences = occurrences
        self.title = title
        listBuilder = ListBasedDetailBuilder(into: scrollContainer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var scrollContainer: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.enableAutoLayout()
        return scroll
    }()

    func buildDetailViewContainer() -> UIView {
        let view = UIView(frame: .zero)
        view.enableAutoLayout()
        view.backgroundColor = .appBackground
        return view
    }

    private func fillBlankField(_ value: String?) -> String {
        value == nil ? String.emptyProperty : value!.fillEmpty()
    }

    private func getDetailsBlock(occurrence: ComplementaryOccurrence) -> DetailsBlock {
        let address = occurrence.address
        let formattedAddress = address.getFormattedAddress(withCoordinates: true)
        let formattedDatetime = occurrence.serviceRegisteredAt?.format()
        let natures = occurrence.natures.map { $0.name }
        let situationLabel = OccurrenceSituationLabel().withSituation(occurrence.situation)
        let items: [[InteractableDetailItem]] = [
            [InteractableDetailItem(fromItem: (title: "Endereço", detail: formattedAddress), hasInteraction: true, hasMapInteraction: true)],
            InteractableDetailItem.noInteraction([
                (title: "Data de registro", detail: fillBlankField(formattedDatetime)),
                (title: "Fuso horário", detail: fillBlankField(occurrence.serviceRegisteredAt?.timeZone))
            ]),
            [InteractableDetailItem(fromItem: (title: "Situação", view: situationLabel))],
            [InteractableDetailItem(fromItem: (title: "Naturezas", tags: natures))]
        ]
        let cardHeader = OccurrenceCardHeader(occurrence: occurrence, mainOccurrence: mainOccurrence)
        let detailsGroup = DetailsGroup(items: items, withCustomHeader: cardHeader)

        return DetailsBlock(groups: [detailsGroup], identifier: occurrence.id.uuidString)
    }

    override func viewDidLoad() {
        view.addSubview(scrollContainer)

        let detailsBlocks = occurrences.map { getDetailsBlock(occurrence: $0) }

        listBuilder.buildDetailsBlocks(detailsBlocks)
        scrollContainer.width(view)

        if occurrences.isEmpty {
            let notFoundLabel = UILabel.build(withSize: 14, alpha: 0.8, color: .appTitle, alignment: .center, text: self.emptyFeedback).enableAutoLayout()
            view.addSubview(notFoundLabel)
            notFoundLabel.width(view).height(50).centerX().top(view, mutiplier: 1)
        }

        NSLayoutConstraint.activate([
            scrollContainer.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollContainer.bottomAnchor, multiplier: 1)
        ])

        listBuilder.setupLayout()
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
