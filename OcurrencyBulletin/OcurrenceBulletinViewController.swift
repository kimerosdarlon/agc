//
//  OcurrenceBulletinViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 21/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon
import CoreDataModels

class OcurrenceBulletinViewController: GenericSearchViewController {

    private var expandedPath: IndexPath?
    var bulletins = [BulletinItem]()
    var isLoading = false
    var serviceType: ServiceType {
        guard let service = self.searchParms["service"] as? String else { return .physical }
        return ServiceType.init(rawValue: service) ?? .physical
    }

    @BulletimDocumentServiceInject
    public var bulletimService: BulletimDocumentService

    override func viewDidLoad() {
        super.viewDidLoad()
        setState(.loading, message: nil)
        search()
        table.separatorStyle = .none
        table.enableAutoLayout()
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        table.register(BulletionOccurencyTableViewCell.self, forCellReuseIdentifier: BulletionOccurencyTableViewCell.identifier)
        dataSource = self
        table.separatorInset = .init(top: 30, left: 0, bottom: 0, right: 0)
        delegate = self
    }

    func search() {
        switch serviceType {
        case .physical, .legal:
            self.getInvolved(type: serviceType)
        case .state:
            searchByStateCode(params: searchParms)
        case .national:
            searcByNationalCode(params: searchParms)
        case .cellphones, .vehicle, .weapons:
            searchByObject(query: searchParms, service: serviceType)
        }
    }

    func handlerRequest(result: Result<[BulletinItem], Error>) {
        switch result {
        case .success(let bulletins):
            self.handlerSucess(bulletins)
        case .failure(let error as NSError):
            self.handlerError(error)
        }
    }

    func searchByObject(query: [String: Any], service: ServiceType) {
        let restService = OccurrenceBulletinService()
        restService.getByObject(params: query, type: service, completion: handlerRequest(result:))
    }

    func getInvolved(type: ServiceType) {
        let service = OccurrenceBulletinService()
        service.getInvolved(params: self.searchParms, type: type) { (result) in
            switch result {
            case .success(let bulletins):
                self.handlerSucess(bulletins)
            case .failure(let error as NSError):
                self.handlerError(error)
            }
        }
    }

    func searchByStateCode(params: [String: Any] ) {
        let state = searchParms["bulletin.state"] as? String ?? ""
        let stateCode = searchParms["stateCode"] as? String ?? ""
        let service = OccurrenceBulletinService()
        service.getByStateCode(state: state, code: stateCode) { (details) in
            switch details {
            case .failure(let error as NSError):
                self.handlerError(error)
            case .success(let details):
                self.showBulletinDetail(details)
            }
        }
    }

    func showBulletinDetail(_ details: BulletinDetails) {
        DispatchQueue.main.async {
            let model = OcurrencyBulletinDetailViewModel(details: details)
            self.title = model.codeNational
            let controller = OcurrencyBulletinDetailViewController(viewModel: model)
            self.addChild(controller)
            let view = controller.view!
            view.alpha = 0
            self.view.addSubview(view)
            view.enableAutoLayout()
            view.fillSuperView()
            UIView.animate(withDuration: 0.4) {
                view.alpha = 1
            }
        }
    }

    func searcByNationalCode( params: [String: Any] ) {
        let nationalCode = searchParms["nationalCode"] as? String ?? ""
        let service = OccurrenceBulletinService()
        service.getByNationalCode(code: nationalCode) { (details) in
            switch details {
            case .failure(let error as NSError):
                self.handlerError(error)
            case .success(let details):
                self.showBulletinDetail(details)
            }
        }
    }

    fileprivate func handlerSucess(_ bulletins: ([BulletinItem])) {
        self.bulletins = bulletins
        var indexList = [IndexPath]()
        for section in 0..<bulletins.count {
            let index = IndexPath(row: 0, section: section)
            indexList.append(index)
        }
        DispatchQueue.main.async {
            if !indexList.isEmpty {
                self.setState(.normal, message: nil)
                self.table.reloadData()
            } else {
                self.setState(.notFound, message: nil)
            }
        }
    }
}

extension OcurrenceBulletinViewController: UITableViewDelegate, UITableViewDataSource, GenericSearchViewControllerDelegate, SearchDelegate {

    func present(controller: UIViewController, completion: (() -> Void)?) {
        self.bulletins.removeAll()
        setState(.loading, message: nil)
        table.reloadData()
        if let controller = controller as? OcurrenceBulletinViewController {
            self.searchParms = controller.searchParms
            self.userInfo = controller.userInfo
            self.search()
            setupInfo()
            collectionParams.reloadData()
        }
        completion?()
    }

    func didClickRetryButton(_ button: UIButton, on state: GenericSearchViewConrtollerState) {
        if state == .serverError {
            setState(.loading, message: nil)
            search()
        } else {
            if isFromSearch {
                didClickOnFilterButton()
                return
            }
            navigationController?.popViewController(animated: true)
        }
    }

    func didClickOnFilterButton() {
        let filterController = OccurrenceBulletinFilterViewController(params: searchParms)
        didClickOnFilterButton(filterController)
    }

    func didClickOnFilterButton(_ filterController: OccurrenceBulletinFilterViewController) {
        filterController.hidesBottomBarWhenPushed = true
        filterController.delegate = self
        navigationController?.pushViewController(filterController, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return bulletins.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bulletins.isEmpty ? 0 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = BulletionOccurencyTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BulletionOccurencyTableViewCell
        cell.selectionStyle = .none
        cell.delegate = self
        let index = indexPath.section
        let bulletin = bulletins[index]
        if let indexExpanded = self.expandedPath {
            if indexPath.section == indexExpanded.section {
                cell.configure(with: bulletin, tag: index, expanded: true)
                return cell
            }
        }
        cell.configure(with: bulletin, tag: index, expanded: false)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            isLoading = true
            requestBulletinDetail(indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }

    func requestBulletinDetail(_ indexPath: IndexPath) {
        let service = OccurrenceBulletinService()
        let bulletinId = bulletins[indexPath.section].id
        let cell = table.cellForRow(at: indexPath) as? BulletionOccurencyTableViewCell
        cell?.setLoading(true)
        service.getDetails(id: bulletinId) { (result) in
            self.handlerDetailResponse(result, indexPath: indexPath)
        }
    }

    func handlerDetailResponse(_ result: Result<BulletinDetails, Error>, indexPath: IndexPath) {
        self.isLoading = false
        DispatchQueue.main.async {
            let cell = self.table.cellForRow(at: indexPath) as? BulletionOccurencyTableViewCell
            cell?.setLoading(false)
            switch result {
            case .success(let details):
                let model = OcurrencyBulletinDetailViewModel(details: details)
                let detailController = OcurrencyBulletinDetailViewController(viewModel: model)
                self.navigationController?.pushViewController(detailController, animated: true)
            case .failure(let error as NSError):
                self.handlerError(error)
            }
        }
    }
}

extension OcurrenceBulletinViewController: OccurrencyBulletinExpandDelegate {

    func toggleExpandBulletin(with id: Int) {
        let animation = UITableView.RowAnimation.automatic
        if let index = self.expandedPath {
            if index.section == id {
                let aux = self.expandedPath!
                self.expandedPath = nil
                table.reloadRows(at: [aux], with: animation)
            } else {
                let aux = self.expandedPath!
                self.expandedPath = nil
                table.reloadRows(at: [aux], with: animation)
                self.expandedPath = IndexPath(row: 0, section: id)
                table.reloadRows(at: [ self.expandedPath! ], with: animation)
            }
        } else {
            self.expandedPath = IndexPath(row: 0, section: id)
            table.reloadRows(at: [expandedPath!], with: animation)
        }
    }
}

extension OcurrenceBulletinViewController: GenericSearchViewControllerDataSource {
    func didReturnNotFoundConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Nenhum boletim foi encontrado para os filtros informados.",
            subtitle: nil, showButtonAction: true, buttonTitle: "Editar filtros")
    }

    func didReturnServerErrorConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (title: "Ocorreu um erro de comunicação com o serviço de boletins.",
            subtitle: nil, showButtonAction: true, buttonTitle: "Tentar novamente")
    }
}
