//
//  WarrantDelegateDataSource.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 08/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

protocol WarrantDelegate: class {
    func addWarrants(at indexPaths: [IndexPath] )
    func didStartRequestMore()
    func noResultsForQuery()
    func didFineshWithError(errorMessage message: String)
}

class WarrantDelegateDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let service = WarrantService()
    weak var delegate: WarrantDelegate?
    private var page = 0
    private var params = [String: Any]()
    private var warrants = [Warrant]()

    func findAllBy(search params: [String: Any], onFinished: @escaping (NSError?) -> Void  ) {
        self.params = params
        self.params["page"] = page
        self.params["size"] = 50
        for param in params {
            self.params[param.key] = "\(param.value)"
        }
        service.findBy(search: self.params ) { (result) in
            switch result {
            case .success(let list):
                onFinished(nil)
                self.warrants = list
                if list.isEmpty {
                    self.delegate?.noResultsForQuery()
                    return
                }
                self.handlerSuccess2(self.warrants)
            case .failure(let error as NSError):
                onFinished(error)
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return warrants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = WarrantTableViewCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MyCustomCell<Warrant>
        cell.configure(using: warrants[indexPath.item])
        if indexPath.last! == warrants.count - 1 {
            requestMore()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    private func requestMore( ) {
        delegate?.didStartRequestMore()
        page += 1
        params["page"] = page
        service.findBy(search: params) { (result) in
            switch result {
            case .success(let list):
                self.handlerSuccess(list)
            case .failure(let error as NSError):
                self.delegate?.didFineshWithError(errorMessage: error.domain)
            }
        }
    }

    func handlerSuccess(_ list: [Warrant]) {
        var indexList = [IndexPath]()
        let startIndex = (warrants.count - 1)
        let finalIndex = list.count + startIndex

        for index in startIndex..<finalIndex {
            indexList.append(IndexPath(row: index, section: 0) )
        }
        warrants += list
        delegate?.addWarrants(at: indexList)
    }

    func handlerSuccess2(_ list: [Warrant]) {
        var indexList = [IndexPath]()
        let startIndex = 0
        let finalIndex = list.count + startIndex

        for index in startIndex..<finalIndex {
            indexList.append(IndexPath(row: index, section: 0) )
        }
        delegate?.addWarrants(at: indexList)
    }

    func warrantFor(indexPath: IndexPath) -> Warrant {
        return warrants[indexPath.item]
    }
}
