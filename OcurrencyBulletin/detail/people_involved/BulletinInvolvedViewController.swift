//
//  BulletinInvolvedViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 04/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletinInvolvedViewController: BulletionDetailTemplateViewController {

    var involveds: [PersonInvolvedDetail] {
        return viewModel.involveds
    }

    override init(viewModel: OcurrencyBulletinDetailViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        dataSource = self
        registerCell(BulletinPeopleInvolvedTableViewCell.self,
                     forCellReuseIdentifier: BulletinPeopleInvolvedTableViewCell.identifier)
        registerCell(BulletinLegalInvolvedTableViewCell.self,
                     forCellReuseIdentifier: BulletinLegalInvolvedTableViewCell.identifier)
        title = "Envolvidos"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BulletinInvolvedViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return involveds.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let involved = involveds[indexPath.section]
        if involved.type == .physical {
            return getPeopleInvolvedCell(tableView, for: indexPath)
        } else {
            return getLegalInvolvedCell(tableView, for: indexPath)
        }
    }

    func getPeopleInvolvedCell( _ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let involved = involveds[indexPath.section]
        let id = BulletinPeopleInvolvedTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! BulletinPeopleInvolvedTableViewCell
        cell.configure(personInvolved: involved, model: viewModel)
        return cell
    }

    func getLegalInvolvedCell( _ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let involved = involveds[indexPath.section]
        let id = BulletinLegalInvolvedTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! BulletinLegalInvolvedTableViewCell
        cell.configure(personInvolved: involved, model: viewModel)
        return cell
    }
}
