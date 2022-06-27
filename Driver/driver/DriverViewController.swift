//
//  DriverViewController.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 13/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class DriverViewController: GenericSearchViewController {

    fileprivate let delegateDataSource = DriverDelegateDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resultados"
        table.register(DriverTableViewCell.self, forCellReuseIdentifier: DriverTableViewCell.identifier )
        view.backgroundColor = .appBackground
        delegateDataSource.delegate = self
        delegate = self
        dataSource = self
        setState(.loading, message: nil)
        search()
    }

    func search() {
        if userInfo["cpf"] != "" && userInfo["cpf"] != nil {
            delegateDataSource.getDriversByCpf(userInfo["cpf"]!, onFinished: onFinished)
        } else if userInfo["cnh"] != "" && userInfo["cnh"] != nil {
            delegateDataSource.getDriversByCnh(userInfo["cnh"]!, onFinished: onFinished)
        } else if userInfo["renach"] != "" && userInfo["renach"] != nil {
            delegateDataSource.getDriversByRenach(userInfo["renach"]!, onFinished: onFinished)
        } else if userInfo["pid"] != "" && userInfo["pid"] != nil {
            delegateDataSource.getDriversByPid(userInfo["pid"]!, onFinished: onFinished)
        }
    }

    func onFinished(error: NSError?) {
        self.handlerError(error)
        garanteeMainThread { [weak self] in
            if let drivers = self?.delegateDataSource.driversList(), drivers.count == 1 {
                let detail = DriverDetailViewController(withDriver: drivers[0])
                if var viewControllers = self?.navigationController?.viewControllers {
                    _ = viewControllers.popLast()
                    viewControllers.append(detail)
                    self?.navigationController?.setViewControllers(viewControllers, animated: true)
                } else {
                    self?.navigationController?.pushViewController(detail, animated: true)
                }
            }
        }
    }
}

extension DriverViewController: DriverDelegate {
    func addDrivers(at indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [unowned self] in
            if table.numberOfRows(inSection: 0) != dataSource?.tableView(table, numberOfRowsInSection: 0) {
                table.insertRows(at: indexPaths, with: .automatic)
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

    func noResultsForQuery() {
        DispatchQueue.main.async {
            self.setState(.notFound, message: nil)
        }
    }
}

extension DriverViewController: GenericSearchViewControllerDelegate, GenericSearchViewControllerDataSource {

    func didReturnNotFoundConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Nenhum condutor foi encontrado para os filtros informados.",
            subtitle: nil,
            showButtonAction: true,
            buttonTitle: "Editar filtros"
        )
    }

    func didReturnServerErrorConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Ocorreu um erro de comunicação com o serviço de condutores.",
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
        let filter = DriverFilterViewController(params: searchParms)
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
        let driver = delegateDataSource.driverFor(indexPath: indexPath)
        let detail = DriverDetailViewController(withDriver: driver)
        navigationController?.pushViewController(detail, animated: true)
    }
}
