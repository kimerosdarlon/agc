//
//  VeiculosViewController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon

class VehicleViewController: GenericSearchViewController {
    private var hasAlreadyRequestedCompleted = false
    lazy var header = VehicleOwnerHeaderView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 0))
    private var vehicles = [Vehicle]()

    private let identifier = String(describing: VehicleTableViewCell.self)

    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    let service = VehicleService()
    var shouldBackToHome = true
    public override func viewDidLoad() {
        super.viewDidLoad()
        setState(.loading, message: nil)
        dataSource = self
        delegate = self
        table.register(VehicleTableViewCell.self, forCellReuseIdentifier: identifier)
        search()
        title = "Veículos"
    }

    func search() {
        service.findBy(params: searchParms, completion: self.handlerResponse(_:))
    }

    override func viewWillAppear(_ animated: Bool) {
        let theme = UserStylePreferences.theme
        view.overrideUserInterfaceStyle = theme.style
        header.overrideUserInterfaceStyle = theme.style
        table.overrideUserInterfaceStyle = theme.style
    }

    func handlerResponse(_ result: Result<[VehicleResult], Error> ) {
        switch result {
        case .success(let data):
            self.handlerSuccess(data)
        case .failure(let error as RequestError):
            DispatchQueue.main.async {
                self.alert(error: error.description) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        case .failure(let error as NSError):
            self.handlerError(error)
        }
    }

    fileprivate func isEmtpyResult(_ data: [VehicleResult]) -> Bool {
        if data.isEmpty {
            DispatchQueue.main.async {
                self.setState(.notFound, message: nil)
            }
            return true
        }
        return false
    }

    fileprivate func mapResultToVehicles(_ list: [VehicleResult]) -> [Vehicle] {
        return list.map { $0.toVehicle() }
    }

//    fileprivate func searchUsing(plate: String, completion: @escaping (([Vehicle]?) -> Void)) {
//        service.findBy(search: plate) { (result) in
//            switch result {
//            case .success(let list):
//                if list.isEmpty { completion(nil) }
//                DispatchQueue.main.async {
//                    completion(self.mapResultToVehicles(list))
//                }
//            case .failure:
//                completion(nil)
//            }
//        }
//    }

//    private func enrichResult(_ result: [VehicleResult], completion: @escaping (([Vehicle]) -> Void)) {
//        var vehicles = mapResultToVehicles(result)
//
//        func enrichVehicle(atIndex index: Int = 0) {
//            func nextOrComplete() {
//                if index == vehicles.endIndex - 1 {
//                    completion(vehicles)
//                } else {
//                    enrichVehicle(atIndex: index + 1)
//                }
//            }
//
//            let data = result[index]
//            if let plate = data.general.plate, !data.completed {
//                searchUsing(plate: plate) { enrichedResult in
//                    if let enrichedResult = enrichedResult, let firstResult = enrichedResult.first {
//                        vehicles[index] = firstResult
//                    }
//
//                    nextOrComplete()
//                }
//            } else {
//                nextOrComplete()
//            }
//        }
//
//        if result.count > 0 {
//            enrichVehicle(atIndex: 0)
//        }
//    }

    func handlerSuccess(_ data: [VehicleResult]) {
        if isEmtpyResult(data) { return }
        self.vehicles = mapResultToVehicles(data)

        if self.vehicles.count == 1 {
            let vehicle = self.vehicles[0]

            if !data[0].completed && (searchParms["type"] as! String) != "plate" {
                self.service.findBy(search: vehicle.plate!) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let list):
                            self.setState(.normal, message: nil)
                            if let detail = list.first {
                                var vehicleDetail = detail.toVehicle()
                                vehicleDetail.completed = true

                                self.showDetailsTo(vehicle: vehicleDetail, usingModal: true) {
                                    if self.shouldBackToHome {
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                }
                            }
                        case .failure(let error):
                            self.handlerRequestError(error)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.setState(.normal, message: nil)
                    self.showDetailsTo(vehicle: vehicle, usingModal: true) {
                        if self.shouldBackToHome {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            return
        } else if self.vehicles.count > 1 {
            if let firstWithOwner = self.vehicles.filter({$0.owner != nil}).first {
                DispatchQueue.main.async {
                    self.header.configure(with: firstWithOwner)
                    self.table.tableHeaderView = self.header
                    self.header.setNeedsLayout()
                    self.header.layoutIfNeeded()
                    self.setState(.normal, message: nil)
                    self.reloadTableView()
                }
            }
        }
    }

}

extension VehicleViewController: GenericSearchViewControllerDataSource, GenericSearchViewControllerDelegate, SearchDelegate {

    func didReturnNotFoundConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Nenhum veículo foi encontrado para os filtros informados.",
            subtitle: nil,
            showButtonAction: true,
            buttonTitle: "Editar filtros"
        )
    }

    func didReturnServerErrorConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?) {
        return (
            title: "Ocorreu um erro de comunicação com o serviço de veículos.",
            subtitle: nil,
            showButtonAction: true,
            buttonTitle: "Tentar novamente"
        )
    }

    func didClickOnFilterButton() {
        let filterController = VehicleFilterViewController(params: searchParms)
        filterController.delegate = self
        navigationController?.pushViewController(filterController, animated: true)
    }

    func present(controller: UIViewController, completion: (() -> Void)?) {
        self.table.tableHeaderView = nil
        setState(.loading, message: nil)
        self.vehicles.removeAll()
        shouldBackToHome = false
        if let copyControler = controller as? VehicleViewController {
            self.searchParms = copyControler.searchParms
            self.userInfo = copyControler.userInfo
            service.findBy(params: searchParms, completion: self.handlerResponse(_:))
        }
        completion?()
    }

    func didClickRetryButton(_ button: UIButton, on state: GenericSearchViewConrtollerState) {
        switch state {
        case .serverError:
            setState(.loading, message: nil)
            self.search()
        default:
            if isFromSearch {
                didClickOnFilterButton()
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vehicles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MyCustomCell<VehicleCellViewModel>
        let vehicle = vehicles[indexPath.item]
        let cellModel = VehicleCellViewModel(vehicle: vehicle)
        cell.configure(using: cellModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vehicle = vehicles[indexPath.item]
        if let completed = vehicle.completed, completed == true {
            self.showDetailsTo(vehicle: vehicle)
            return
        }

        self.table.addSubview(loadingIndicator)
        loadingIndicator.enableAutoLayout()
        loadingIndicator.backgroundColor = UIColor.appBackground.withAlphaComponent(0.4)
        loadingIndicator.startAnimating()
        loadingIndicator.fillSuperView()
        self.service.findBy(search: vehicle.plate!) { (result) in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.removeFromSuperview()
                switch result {
                case .success(let list):
                    if let detail = list.first {
                        var vehicleDetail = detail.toVehicle()
                        vehicleDetail.completed = true
                        self.vehicles[indexPath.item] = vehicleDetail
                        self.showDetailsTo(vehicle: vehicleDetail)
                    }
                case .failure(let error):
                    self.handlerRequestError(error)
                }
            }
        }
    }

    func showDetailsTo(vehicle: Vehicle, usingModal: Bool = false, completion: ( () -> Void)?  = nil ) {
        let model = VehicleDetailViewModel(vehicle: vehicle)
        let detailController = VehicleDetailViewController(vehicleDetail: model)
        if usingModal {
            title = "Detalhes"
            addChild(detailController)
            let detailView = detailController.view!
            detailView.alpha = 0
            view.addSubview(detailView)
            detailView.enableAutoLayout()
            detailView.fillSuperView()
            UIView.animate(withDuration: 0.5) {
                detailView.alpha = 1.0
            }
        } else {
            navigationController?.pushViewController(detailController, animated: true)
        }
    }
}
