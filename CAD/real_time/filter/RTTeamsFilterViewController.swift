//
//  RTTeamsFilterViewController.swift
//  CAD
//
//  Created by Samir Chaves on 17/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class RTTeamsFilterViewController: UIViewController, RTFilterViewController {
    private let manager: TeamMembersManager

    @CadServiceInject
    private var cadService: CadService

    @RealTimeServiceInject
    private var realTimeService: RealTimeService

    private let titleLabel = UILabel.build(withSize: 15, weight: .bold, color: .appTitle, text: "Regiões de Atuação da sua equipe")
    private let subtitleLabel = UILabel.build(withSize: 13, alpha: 0.7, color: .appTitle, text: "Selecione uma ou mais opções para visualizar as equipes ativas em cada região")
    private let operatingRegionsField = TagsFieldComponent<UUID>(fieldName: "Regiões de Atuação", tags: [], multipleChoice: true).enableAutoLayout()

    private var selectedOperatingRegions = [UUID]()

    init(manager: TeamMembersManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
        title = "Equipes"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .appBackground

        manager.addDelegate(self)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(operatingRegionsField)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            operatingRegionsField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 15),
            operatingRegionsField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            operatingRegionsField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])

        loadOperatingRegions()
        operatingRegionsField.onSelect = { (_, selected) in
            if selected.isEmpty {
                self.realTimeService.switchToMyTeamStream()
            } else {
                let selectedOperatingRegions = selected.compactMap { $0.key }
                self.realTimeService.switchToOperatingRegionsStream(ids: selectedOperatingRegions)
                self.selectedOperatingRegions = selectedOperatingRegions
                self.manager.updateTeams(operatingRegions: selectedOperatingRegions)
            }
        }
    }

    private func loadOperatingRegions() {
        guard let activeTeam = cadService.getActiveTeam() else { return }
        let operatingRegions = activeTeam.operatingRegions
        let tags = operatingRegions.map { (key: $0.id, value: $0.initials) }
        operatingRegionsField.setTags(tags)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.operatingRegionsField.selectTags(Set(tags.map { $0.key }))
        }
    }

    func didClean() {
        self.selectedOperatingRegions = []
        self.operatingRegionsField.clear()
        self.realTimeService.switchToMyTeamStream()
    }
}

extension RTTeamsFilterViewController: TeamMembersManagerDelegate {
    func didUpdateTeams() {
        let teams = manager.getOnlineTeams()
        let operatingRegions = teams.flatMap { $0.operatingRegions }
            .uniqued()
            .map { (key: $0.id, value: "\($0.initials) / \($0.agency.initials)") }
        operatingRegionsField.setTags(operatingRegions)
    }
}
