//
//  NewTemplateTeamViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 10/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class NewTemplateTeamViewController: UIViewController {

    weak var delegate: TeamFormDelegate?

    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNewTemplate))

        return button
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        view.backgroundColor = .appBackground
        title = "Novo Modelo"
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = cancelButton
    }

    @objc
    private func saveNewTemplate() {
        self.dismiss(animated: true) { [weak self] in
            let team = CadResoureFactory.mockTeam()
            self?.delegate?.newTemplate(team)
        }
    }

    @objc
    private func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
