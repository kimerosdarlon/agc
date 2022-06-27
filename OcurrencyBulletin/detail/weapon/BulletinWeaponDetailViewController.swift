//
//  BulletinWeaponDetailViewController.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletinWeaponDetailViewController: BulletionDetailTemplateViewController {

    override init(viewModel: OcurrencyBulletinDetailViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        dataSource = self
        registerCell(WeaponDetailTableViewCell.self,
                     forCellReuseIdentifier: WeaponDetailTableViewCell.identifier)
        title = "Armas"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BulletinWeaponDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.weapons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = WeaponDetailTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WeaponDetailTableViewCell
        let isExpanded = expandedIndexPaths.contains(indexPath)
        let weapon = viewModel.weapons[indexPath.section]
        cell.configure(withWeapon: weapon, andModel: viewModel, isExpanded: isExpanded)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedIndexPaths.contains(indexPath) {
            expandedIndexPaths.removeAll(where: {$0 == indexPath})
        } else {
            expandedIndexPaths.append(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
