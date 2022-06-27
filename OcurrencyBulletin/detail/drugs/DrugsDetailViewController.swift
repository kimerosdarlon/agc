//
//  DrugsDetailViewController.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 03/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
class DrugsDetailViewController: BulletionDetailTemplateViewController {

    override init(viewModel: OcurrencyBulletinDetailViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        dataSource = self
        registerCell(DrugsDetailTableViewCell.self,
                     forCellReuseIdentifier: DrugsDetailTableViewCell.identifier)
        title = "Drogas"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DrugsDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.drugs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = DrugsDetailTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DrugsDetailTableViewCell
        let isExpanded = expandedIndexPaths.contains(indexPath)
        let drug = viewModel.drugs[indexPath.section]
        cell.configure(withDrugs: drug, andModel: viewModel, isExpanded: isExpanded)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if expandedIndexPaths.contains(indexPath) {
            expandedIndexPaths.removeAll(where: {$0 == indexPath})
        } else {
            expandedIndexPaths.append(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
