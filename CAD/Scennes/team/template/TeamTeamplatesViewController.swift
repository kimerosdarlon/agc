//
//  TeamTeamplatesViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 10/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class TeamTemplateViewController: UIViewController {

    private let addButton = FloatButton()
    private var templates: [CadResourceViewModel]
    init(templates: [CadResourceViewModel]) {
        self.templates = templates
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        view.addSubview(addButton)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: addButton.trailingAnchor, multiplier: 3),
            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: addButton.bottomAnchor, multiplier: 3)
        ])
        addButton.addTarget(self, action: #selector(addButtonDidClicked), for: .touchUpInside)
        setupEmtpyStateIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func addButtonDidClicked() {
        let formController = NewTemplateTeamViewController()
        formController.delegate = self
        let navigation = UINavigationController(rootViewController: formController)
        self.present(navigation, animated: true, completion: nil)
    }

    func setupEmtpyStateIfNeeded() {
        if !templates.isEmpty { return }
        let subtitle = "Crie um modelo a partir de uma equipe agendada ou tocando no botão '+' logo abaixo"
        let emptyView = EmptyStateView(title: "Nenhum modelo de equipes foi criado",
                                       subTitle: subtitle,
                                       image: UIImage(named: "equipe")! )
        view.addSubview(emptyView)
        emptyView.enableAutoLayout().fillSuperView()
        view.insertSubview(addButton, aboveSubview: emptyView)
    }
}

extension TeamTemplateViewController: TeamFormDelegate {

    func newTemplate(_ team: Team) {

    }
}
