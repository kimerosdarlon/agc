//
//  OccurrenceDispatchesDetailViewController.swift
//  CAD
//
//  Created by Samir Chaves on 16/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class OccurrenceDispatchesDetailViewController: UIViewController {

    private var detail: OccurrenceDetails!
    private let dateFormatter = DateFormatter()
    private let datetimeFormatter = DateFormatter()
    private lazy var detailsContainer = ListBasedDetailTableView(padding: .init(top: 15, left: 15, bottom: 0, right: 15)).enableAutoLayout()

    init(with occurrence: OccurrenceDetails) {
        super.init(nibName: nil, bundle: nil)
        detail = occurrence
        title = "Empenhos"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buildDetailViewContainer() -> UIView {
        let view = UIView(frame: .zero)
        view.enableAutoLayout()
        view.backgroundColor = .appBackground
        return view
    }

    private func fillBlankField(_ value: String?) -> String {
        value == nil ? String.emptyProperty : value!.fillEmpty()
    }

    private func formatDate(_ dateOpt: Date?) -> String {
        if let date = dateOpt {
            return dateFormatter.string(from: date)
        }

        return "————"
    }

    @objc private func showTeamModal(_ gesture: UITapGestureRecognizer) {
        if let selectedDispatchIndex = gesture.view?.tag, selectedDispatchIndex >= 0 {
            let selectedDispatch = detail.dispatches[selectedDispatchIndex]
            self.present(TeamModalViewController(teamId: selectedDispatch.team.id), animated: true)
        }
    }

    private func getDetailsBlock(dispatch: Dispatch) -> DetailsBlock {
        let dateTime = dispatch.getDate(format: "yyyy-MM-dd'T'HH:mm:ss")
        var formattedDateTime = dateTime?.format(to: "dd/MM/yyyy HH:mm:ss")
        formattedDateTime = formattedDateTime.map { s in "\(s) \(dispatch.timeZone)" }
        let titleLabel = UILabel.build(withSize: 15, weight: .bold, color: .appTitle, text: dispatch.team.name)
        titleLabel.tag = detail.dispatches.firstIndex(where: { $0.team.id == dispatch.team.id }) ?? -1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showTeamModal(_:)))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGesture)
        titleLabel.attributedText = NSAttributedString(string: dispatch.team.name, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        titleLabel.frame.size = .init(width: view.frame.width, height: 30)
        let detailsGroup = DetailsGroup(items: [
            [(title: "Despachante", detail: dispatch.operator.name), (title: "Status", detail: dispatch.status)],
            [(title: "Data", detail: fillBlankField(formattedDateTime))],
            [(title: "Relato", detail: fillBlankField(dispatch.report))]
        ], withCustomHeader: titleLabel)

        return DetailsBlock(group: detailsGroup, identifier: dispatch.dateTime + dispatch.team.id.uuidString)
    }

    override func viewDidLoad() {
        view.addSubview(detailsContainer)
        detailsContainer.delaysContentTouches = true
        detailsContainer.canCancelContentTouches = false
        
        if detail.dispatches.isEmpty {
            let notFoundLabel = UILabel.build(withSize: 14, alpha: 0.8, color: .appTitle, alignment: .center, text: "Nenhum empenho presente nesta ocorrência.").enableAutoLayout()
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

        let dispatchesBlocks = detail.dispatches.map { getDetailsBlock(dispatch: $0) }
        detailsContainer.apply(blocks: dispatchesBlocks)
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
