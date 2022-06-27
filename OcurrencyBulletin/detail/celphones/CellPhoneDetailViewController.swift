//
//  BulletinCellPhoneViewController.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class CellPhoneDetailViewController: BulletionDetailTemplateViewController {

    override init(viewModel: OcurrencyBulletinDetailViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        dataSource = self
        registerCell(CellphoneDetailTableViewCell.self,
                     forCellReuseIdentifier: CellphoneDetailTableViewCell.identifier)
        title = "Celulares"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CellPhoneDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.cellphones.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = CellphoneDetailTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CellphoneDetailTableViewCell
        let isExpanded = expandedIndexPaths.contains(indexPath)
        let phone = viewModel.cellphones[indexPath.section]
        cell.configure(withCellphone: phone, andModel: viewModel, isExpanded: isExpanded)
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
