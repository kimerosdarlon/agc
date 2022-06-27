//
//  SettingsViewController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 22/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import SinespSegurancaAuthMobile
import AgenteDeCampoCommon
import CAD

class SettingsViewController: UITableViewController {
    private let equipmentPicker = EquipmentPickerConfigViewController()

    private var controllers: [[SettingsOption]] {
        return [
            [
                AppVersion()
            ],
            [
                UserStylePreferences(style: .insetGrouped),
                equipmentPicker,
                TouchAnFaceIdSettingsViewController(),
                RecentsTableViewController(),
                PrivacyPoliciesSettingsViewController(),
                TermsAgreementSettingsViewController()
            ]
        ]
    }

    private var logoutButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Sair", for: .normal)
        button.backgroundColor = .appBackgroundCell
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.enableAutoLayout()
        button.width(60).height(40)
        return button
    }()

    override init(style: UITableView.Style) {
        super.init(style: style)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeCount), name: .updateBadgeCount, object: nil)
        updateBadgeCount()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "settingsCell")
        view.backgroundColor = .appBackground
        tableView.dataSource = self
        title = "Configurações"
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        definesPresentationContext = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Voltar", style: .plain, target: nil, action: nil)

        equipmentPicker.setActiveTeam()
        NotificationCenter.default.addObserver(self, selector: #selector(cadResourceDidChange), name: .cadResourceDidChange, object: nil)
    }

    @objc
    func cadResourceDidChange() {
        garanteeMainThread {
            self.equipmentPicker.setActiveTeam()
        }
    }

    @objc
    func updateBadgeCount() {
        tabBarItem.badgeValue = "\(UIApplication.shared.applicationIconBadgeNumber)"
        tableView.reloadData()
    }

    @objc
    func logout() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: "Sair da conta?", style: .default) { (_) in
            let key = ACEnviroment.shared.appServerKey
            let service = SinespAuthService(appServerKey: key, enviroment: .dev,
                                            systemInitials: ACEnviroment.shared.systemInitials)
            service.logout { (_) in
                DispatchQueue.main.async {
                    TokenService().clearAll()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "Versão \(version).\(build)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsCell
        cell.backgroundColor = .appBackgroundCell
        let controller = controllers[indexPath.section][indexPath.item]
        if controller.shouldPresent() {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        if controller.enabled() {
            cell.selectionStyle = .default
            cell.isUserInteractionEnabled = true
            cell.contentView.alpha = 1
        } else {
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            cell.contentView.alpha = 0.6
        }
        cell.setBadge(value: controller.getBadge())
        cell.textLabel?.text = controller.settingsTitle()
        cell.detailTextLabel?.text = controller.settingsSubTitle()
        cell.imageView?.image = controller.settingsIcon()
        cell.accessoryView = controller.accesoryView()
        cell.textLabel?.textColor = .appCellLabel
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return controllers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllers[section].count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = controllers[indexPath.section][indexPath.item]
        if controller.shouldPresent() {
            if let viewController = controller as? UIViewController {
                navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            controller.runAction(in: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        equipmentPicker.setActiveTeam()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section < controllers.count - 1 {
            return nil
        }
        let view = UIView()
        view.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        return view
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 16 : 80
    }
}

class SettingsCell: UITableViewCell {

    private let lblBadge = UILabel.init(frame: .zero)

    func setBadge(value: Int) {
        if value <= 0 { return }
        lblBadge.backgroundColor = .systemRed
        lblBadge.clipsToBounds = true
        let size: CGFloat = 20
        lblBadge.enableAutoLayout().height(size).width(size)
        lblBadge.layer.cornerRadius = size/2
        lblBadge.textColor = UIColor.white
        lblBadge.font = UIFont.robotoRegular.withSize(14)
        lblBadge.textAlignment = .center
        lblBadge.text = "\(value)"
        addSubview(lblBadge)
        NSLayoutConstraint.activate([
            lblBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: lblBadge.trailingAnchor, multiplier: 3)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        lblBadge.removeFromSuperview()
    }
}
