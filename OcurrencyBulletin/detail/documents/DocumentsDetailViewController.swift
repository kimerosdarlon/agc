//
//  DocumentsDetailViewController.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class DocumentsDetailViewController: BulletionDetailTemplateViewController {

    override init(viewModel: OcurrencyBulletinDetailViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        dataSource = self
        registerCell(DocumentsDetailTableViewCell.self,
                     forCellReuseIdentifier: DocumentsDetailTableViewCell.identifier)
        title = "Documentos"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DocumentsDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = DocumentsDetailTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DocumentsDetailTableViewCell
        let isExpanded = expandedIndexPaths.contains(indexPath)
        let other = viewModel.documents[indexPath.section]
        cell.configure(withDocument: other, andModel: viewModel, isExpanded: isExpanded)
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
