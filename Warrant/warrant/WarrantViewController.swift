//
//  WarrantViewController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
import CoreDataModels

class WarrantViewController: GenericSearchViewController {

    private let delegateDataSource = WarrantDelegateDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mandados de prisão"
        table.register(WarrantTableViewCell.self, forCellReuseIdentifier: WarrantTableViewCell.identifier )
        view.backgroundColor = .appBackground
        delegateDataSource.delegate = self
        delegate = self
        dataSource = self
        setState(.loading, message: nil)
        search()
    }

    func search() {
        delegateDataSource.findAllBy(search: searchParms, onFinished: self.handlerError(_:))
    }
}

extension WarrantViewController: WarrantDelegate {

    func addWarrants(at indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [unowned self] in
            if table.numberOfRows(inSection: 0) != dataSource?.tableView(table, numberOfRowsInSection: 0) {
                table.insertRows(at: indexPaths, with: .top)
            } else {
                table.reloadRows(at: indexPaths, with: .automatic)
            }
            self.setState(.normal, message: nil)
        }
    }

    func didFineshWithError(errorMessage message: String) {
        DispatchQueue.main.async {
            self.table.backgroundView?.removeFromSuperview()
            self.table.tableFooterView = nil
            self.acvityIndicator.stopAnimating()
            self.acvityIndicator.removeFromSuperview()
            let view = UIView(frame: .init(x: 0, y: 0, width: self.table.frame.width, height: 80))
            let label = UILabel()
            label.font = UIFont.robotoRegular.withSize(16)
            label.textColor = .appCellLabel
            label.numberOfLines = 0
            label.textAlignment = .center
            label.text = message
            label.enableAutoLayout()
            view.addSubview(label)
            label.fillSuperView()
            self.table.tableFooterView = view
        }
    }

    func didStartRequestMore() {
        self.setState(.loadingMore, message: nil)
    }

    func noResultsForQuery() {
        DispatchQueue.main.async {
            self.setState(.notFound, message: nil)
        }
    }
}

extension WarrantViewController: GenericSearchViewControllerDelegate, GenericSearchViewControllerDataSource {

    func didReturnNotFoundConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Nenhum mandado foi encontrado para os filtros informados.",
            subtitle: nil,
            showButtonAction: true,
            buttonTitle: "Editar filtros"
        )
    }

    func didReturnServerErrorConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Ocorreu um erro de comunicação com o serviço de mandados.",
            subtitle: nil,
            showButtonAction: true,
            buttonTitle: "Tentar novamente"
        )
    }

    func didClickRetryButton(_ button: UIButton, on state: GenericSearchViewConrtollerState) {
        switch state {
        case .serverError:
            setState(.loading, message: nil)
            search()
        default:
            if isFromSearch {
                didClickOnFilterButton()
                return
            }
            navigationController?.popViewController(animated: true)
        }
    }

    func didClickOnFilterButton() {
        let filter = WarrantFilterViewController(params: searchParms)
        filter.formController?.loadTextFields()
        navigationController?.pushViewController(filter, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegateDataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return delegateDataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return delegateDataSource.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let warrant = delegateDataSource.warrantFor(indexPath: indexPath)
        let detail = WarrantDetailViewController(with: warrant)
        navigationController?.pushViewController(detail, animated: true)
    }
}
