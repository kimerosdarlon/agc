//
//  DriverDelegateDataSource.swift
//  Driver
//
//  Created by Samir Chaves on 13/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

protocol DriverDelegate: class {
    func addDrivers(at indexPaths: [IndexPath] )
    func noResultsForQuery()
    func didFineshWithError(errorMessage message: String)
}

class DriverDelegateDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let service = DriverSearchService()
    weak var delegate: DriverDelegate?
    private var drivers = [Driver]()

    private func handleCompletion(_ result: Result<[Driver], Error>) -> NSError? {
        switch result {
        case .success(let drivers):
            self.drivers = drivers
            if drivers.isEmpty {
                self.delegate?.noResultsForQuery()
                return nil
            }
            self.handlerSuccess(drivers)
            return nil
        case .failure(let error as NSError):
            return error
        }
    }

    func getDriversByCpf(_ cpf: String, onFinished: @escaping (NSError?) -> Void) {
        service.getDriversByCpf(cpf) { result in
            onFinished(self.handleCompletion(result))
        }
    }

    func getDriversByCnh(_ cnh: String, onFinished: @escaping (NSError?) -> Void) {
        service.getDriversByCnh(cnh) { result in
            onFinished(self.handleCompletion(result))
        }
    }

    func getDriversByRenach(_ renach: String, onFinished: @escaping (NSError?) -> Void) {
        service.getDriversByRenach(renach) { result in
            onFinished(self.handleCompletion(result))
        }
    }

    func getDriversByPid(_ pid: String, onFinished: @escaping (NSError?) -> Void) {
        service.getDriversByPid(pid) { result in
            onFinished(self.handleCompletion(result))
        }
    }

    func driversList() -> [Driver] {
        return drivers
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drivers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = DriverTableViewCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }

        (cell as! MyCustomCell<Driver>).configure(using: drivers[indexPath.item])
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func handlerSuccess(_ list: [Driver]) {
        delegate?.addDrivers(at: list.enumerated().map { (index, _) in
            IndexPath(row: index, section: 0)
        })
    }

    func driverFor(indexPath: IndexPath) -> Driver {
        return drivers[indexPath.item]
    }
}
