//
//  DriverDelegateDataSource.swift
//  Driver
//
//  Created by Samir Chaves on 13/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

protocol OccurrenceDelegate: class {
    func addOccurrences(at indexPaths: [IndexPath] )
    func noResultsForQuery()
    func didFineshWithError(errorMessage message: String)
}

class OccurrenceDelegateDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    @OccurrenceServiceInject
    private var service: OccurrenceService

    weak var delegate: OccurrenceDelegate?
    private var occurrences = [SimpleOccurrence]()

    func search(filters: [String: Any], onFinished: @escaping (NSError?) -> Void) {
        service.search(filters) { result in
            onFinished(self.handleCompletion(result))
        }
    }

    private func handleCompletion(_ result: Result<[SimpleOccurrence], Error>) -> NSError? {
        switch result {
        case .success(let occurrences):
            self.occurrences = occurrences
            if occurrences.isEmpty {
                self.delegate?.noResultsForQuery()
                return nil
            } else if occurrences.count > 1 {
                self.handlerSuccess(occurrences)
            }
            return nil
        case .failure(let error as NSError):
            return error
        }
    }

    func occurrencesList() -> [SimpleOccurrence] {
        return occurrences
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return occurrences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = OccurrenceTableViewCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }

        (cell as! MyCustomCell<SimpleOccurrence>).configure(using: occurrences[indexPath.item])
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 205
    }

    func handlerSuccess(_ list: [SimpleOccurrence]) {
        delegate?.addOccurrences(at: list.enumerated().map { (index, _) in
            IndexPath(row: index, section: 0)
        })
    }

    func occurrenceFor(indexPath: IndexPath) -> SimpleOccurrence {
        return occurrences[indexPath.item]
    }
}
