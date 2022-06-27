//
//  BulletinBasicDataViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 03/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class BulletinBasicDataViewController: BulletionDetailTemplateViewController {

    override init(viewModel: OcurrencyBulletinDetailViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        dataSource = self
        registerCell(BulletinBasicDataViewCell.self,
                     forCellReuseIdentifier: BulletinBasicDataViewCell.identifier)
        title = "Dados Básicos"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BulletinBasicDataViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.hasStory ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = BulletinBasicDataViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! BulletinBasicDataViewCell
        if indexPath.section == 0 {
            cell.configure(using: viewModel)
        } else {
            cell.configureStory(using: viewModel)
        }
        return cell
    }
}
