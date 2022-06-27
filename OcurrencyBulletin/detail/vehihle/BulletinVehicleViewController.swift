//
//  BulletinVehicleViewController.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 29/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletinVehicleViewController: BulletionDetailTemplateViewController {

    override init(viewModel: OcurrencyBulletinDetailViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        dataSource = self
        registerCell(BulletinVehicleDetailTableViewCell.self,
                     forCellReuseIdentifier: BulletinVehicleDetailTableViewCell.identifier)
        title = "Veículos"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BulletinVehicleViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func numberOfSections(in tableView: UITableView) -> Int { viewModel.vehicles.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = BulletinVehicleDetailTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BulletinVehicleDetailTableViewCell
        let isExpanded = expandedIndexPaths.contains(indexPath)
        let vehicle = viewModel.vehicles[indexPath.section]
        cell.configure(withVehicle: vehicle, andModel: viewModel, isExpanded: isExpanded)
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
