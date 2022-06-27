//
//  TouchAnFaceIdSettingsViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 05/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import SinespSegurancaAuthMobile
import AgenteDeCampoCommon

class TouchAnFaceIdSettingsViewController: CustomViewController {

    let table = UITableView(frame: .zero, style: .insetGrouped)
    let options: [AuthenticationType] = [.biometrics, .manual, .ask]
    let identifier = "securityCellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        table.enableAutoLayout()
        table.fillSuperView(regardSafeArea: true)
        table.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        view.backgroundColor = .appBackground
        table.backgroundColor = .appBackground
        table.delegate = self
        table.dataSource = self
        title = self.settingsTitle()
    }
}

extension TouchAnFaceIdSettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = titleFor(type: options[indexPath.item])
        let currentOption = SinespAuthService.userAutehnticationPreferences()
        if currentOption == options[indexPath.item] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.textColor = .appCellLabel
        cell.backgroundColor = .appBackgroundCell
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SinespAuthService.setUserAutehnticationPreferences(options[indexPath.item])
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.reloadData()
    }

    func titleFor(type: AuthenticationType) -> String {
        switch type {
        case .ask:
            return "Pergunta na próxima vez"
        case .biometrics:
            return "Usar touch/face id"
        case .manual:
            return "Não usar"
        }
    }

}

extension TouchAnFaceIdSettingsViewController: SettingsOption {

    func settingsTitle() -> String {
        "Segurança"
    }

    func settingsSubTitle() -> String {
        "Configure preferências de segurança"
    }

    func settingsIcon() -> UIImage {
        UIImage(systemName: "lock.shield")!
    }

    func accesoryView() -> UIView? {
        nil
    }
}
