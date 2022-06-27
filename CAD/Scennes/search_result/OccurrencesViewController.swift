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

class OccurrencesViewController: GenericSearchViewController {

    @OccurrenceServiceInject
    private var service: OccurrenceService
    fileprivate let delegateDataSource = OccurrenceDelegateDataSource()
    private var serviceParams = [String: Any]()

    var headerView: UIView = UIView(frame: .zero).enableAutoLayout().height(50)
    var labelView: UILabel = UILabel.build(withSize: 15, alpha: 0.5).enableAutoLayout()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: table.frame.size.width, height: 1)
        topBorder.backgroundColor = UIColor.appTitle.withAlphaComponent(0.1).cgColor
        headerView.layer.addSublayer(topBorder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resultados"
        table.separatorStyle = .none

        headerView.addSubview(labelView)
        labelView.centerY(view: headerView)

        table.tableHeaderView = headerView
        table.register(OccurrenceTableViewCell.self, forCellReuseIdentifier: OccurrenceTableViewCell.identifier)
        view.backgroundColor = .appBackground
        delegateDataSource.delegate = self
        delegate = self
        dataSource = self
        setState(.loading, message: nil)
        if let searchParms = searchParms as? [String: [String: Any?]] {
            for (key, value) in searchParms where value["serviceValue"] != nil {
                if let serviceValue = value["serviceValue"]! {
                    serviceParams[key] = serviceValue
                }
            }
        } else {
            serviceParams = searchParms
        }
        search()
    }

    func search() {
        delegateDataSource.search(filters: serviceParams, onFinished: onFinished)
    }

    func onFinished(error: NSError?) {
        self.handlerError(error)
        let occurrences = delegateDataSource.occurrencesList()
        garanteeMainThread {
            var count = "\(occurrences.count)"
            if occurrences.count < 10 && occurrences.count > 0 {
                count = "0\(count)"
            }
            self.labelView.attributedText = NSAttributedString(string: "\(count) ocorrência(s)", attributes: [
                .font: UIFont.italicSystemFont(ofSize: 14)
            ])
        }
        if occurrences.count == 1 {
            self.goToDetails(of: occurrences.first!.id, keepNavigationHistory: false)
        }
    }

    func hideResult() {
        table.visibleCells.forEach { cell in
            UIView.animate(withDuration: 0.2, animations: {
                cell.alpha = 0
            }, completion: { _ in
                cell.isHidden = true
            })
        }
    }

    func showResult() {
        table.visibleCells.forEach { cell in
            cell.isHidden = false
            UIView.animate(withDuration: 0.2) {
                cell.alpha = 1
            }
        }
    }

    func goToDetails(of occurrenceId: UUID, keepNavigationHistory: Bool = true) {
        garanteeMainThread {
            self.setState(.loading, message: nil)
            self.hideResult()
            UIView.animate(withDuration: 0.2) {
                self.labelView.alpha = 0
            }
        }
        self.service.getOccurrenceById(occurrenceId) { result in
            switch result {
            case .success(let details):
                garanteeMainThread {
                    let detailsPage = OccurrenceDetailViewController(occurrence: details)
                    if var viewControllers = self.navigationController?.viewControllers, !keepNavigationHistory {
                        _ = viewControllers.popLast()
                        viewControllers.append(detailsPage)
                        self.navigationController?.setViewControllers(viewControllers, animated: true)
                    } else {
                        self.navigationController?.pushViewController(detailsPage, animated: true)
                    }
                    self.setState(.normal, message: nil)
                    self.showResult()
                    self.labelView.alpha = 0.5
                }
            case .failure(let error as NSError):
                garanteeMainThread {
                    if self.isUnauthorized(error) {
                        return self.gotoLogin(error.domain)
                    }
                    self.showErrorPage(title: "Não foi possível carregar os detalhes da ocorrência.", error: error, onRetry: {
                        garanteeMainThread {
                            self.goToDetails(of: occurrenceId, keepNavigationHistory: keepNavigationHistory)
                        }
                    })
                }
            }
        }
    }
}

extension OccurrencesViewController: OccurrenceDelegate {
    func addOccurrences(at indexPaths: [IndexPath]) {
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

extension OccurrencesViewController: GenericSearchViewControllerDelegate, GenericSearchViewControllerDataSource {

    func didReturnNotFoundConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Nenhuma ocorrência foi encontrada para os filtros informados.",
            subtitle: nil,
            showButtonAction: true,
            buttonTitle: "Editar filtros"
        )
    }

    func didReturnServerErrorConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Ocorreu um erro de comunicação com o serviço de busca de ocorrências.",
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
        let filter = CadFilterViewController(params: serviceParams)
//        filter.formController?.loadTextFields()
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
        let occurrence = delegateDataSource.occurrenceFor(indexPath: indexPath)
        goToDetails(of: occurrence.id)
    }
}
