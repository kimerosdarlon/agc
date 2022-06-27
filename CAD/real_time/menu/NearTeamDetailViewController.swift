//
//  NearTeamDetailViewController.swift
//  CAD
//
//  Created by Samir Chaves on 12/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class NearTeamDetailViewController: UIViewController {
    weak var delegate: NearTeamDetailDelegate? {
        didSet {
            detailsView?.teamDelegate = delegate
        }
    }

    private var teamDetails: NonCriticalTeam
    private var listBuilder: ListBasedDetailBuilder?
    private let teamMembersManager = TeamMembersManager.shared

    @CadServiceInject
    private var cadService: CadService

    private let backButton: UIButton = {
        let image = UIImage(systemName: "xmark")?.withTintColor(UIColor.appTitle.withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .custom)
        btn.frame = .init(x: 5, y: 5, width: 40, height: 40)
        btn.layer.cornerRadius = btn.bounds.height * 0.5
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 13)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(backPage), for: .touchUpInside)
        return btn.enableAutoLayout().height(40).width(40)
    }()

    @objc func backPage() {
        delegate?.didCloseDetails()
        navigationController?.popViewController(animated: true)
    }

    private var detailsView: NearTeamDetailView?

    init(team: NonCriticalTeam) {
        self.teamDetails = team
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .appBackground
        modalPresentationStyle = .custom
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func renderDetails() {

        var onlinePeopleCpf = teamMembersManager.getPositionedMembers()
            .map { $0.person.person.cpf }
            .compactMap { $0 }
        if let userCpf = cadService.getProfile()?.person.cpf {
            onlinePeopleCpf.append(userCpf)
        }
        self.detailsView = NearTeamDetailView(
            team: teamDetails, onlineMembersCpfs: onlinePeopleCpf
        ).enableAutoLayout()

        guard let detailsView = self.detailsView else { return }
        view.addSubview(detailsView)
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            detailsView.topAnchor.constraint(equalTo: view.topAnchor),
            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            view.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor),

            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.renderDetails()
    }
}
