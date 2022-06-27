//
//  NewScheduleTeamViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 10/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class NewScheduleTeamViewController: UIViewController {

    weak var delegate: TeamFormDelegate?

    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNewScheduleTeam))
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
        title = "Novo Agendamento"
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = cancelButton
    }

    @objc
    private func saveNewScheduleTeam() {
        self.dismiss(animated: true) { [weak self] in
            let team = CadResoureFactory.mockTeam()
            self?.delegate?.newScheduled(team)
        }
    }

    @objc
    private func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
