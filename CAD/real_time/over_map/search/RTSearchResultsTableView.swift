//
//  RTSearchResultsTableView.swift
//  CAD
//
//  Created by Samir Chaves on 06/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

protocol RTSearchResultsTableDelegate: class {
    func didSelectAnOccurrenceResult(_ occurrence: SimpleOccurrence)
    func didSelectATeamResult(_ team: NonCriticalTeam)
    func didSelectARecentSearch(_ query: String)
}

class RTSearchResultsTableView: UITableView {
    enum Section {
        case results, recents
    }

    weak var resultsDelegate: RTSearchResultsTableDelegate?

    private var results = [RTSearchResult]()
    private var recentSearches = [String]()
    private let countLabel = UILabel.build(withSize: 12, color: .appTitle)
    private let notFoundLabel = UILabel.build(withSize: 12, color: .appTitle, alignment: .center, text: "Nenhum resultado para a busca atual.")

    typealias ResultsDataSource = UITableViewDiffableDataSource<Section, RTSearchResult>
    typealias ResultsSnapshot = NSDiffableDataSourceSnapshot<Section, RTSearchResult>
    typealias RecentsDataSource = UITableViewDiffableDataSource<Section, String>
    typealias RecentsSnapshot = NSDiffableDataSourceSnapshot<Section, String>
    private var resultsDataSource: ResultsDataSource?
    private var recentsDataSource: RecentsDataSource?

    init() {
        super.init(frame: .zero, style: .plain)
        resultsDataSource = makeResultsDataSource()
        recentsDataSource = makeRecentsDataSource()
        register(RTRecentSearchCell.self, forCellReuseIdentifier: RTRecentSearchCell.identifier)
        register(RTSearchResultTeamTableCell.self, forCellReuseIdentifier: RTSearchResultTeamTableCell.identifier)
        register(RTSearchResultOccurrenceTableCell.self, forCellReuseIdentifier: RTSearchResultOccurrenceTableCell.identifier)

        backgroundColor = .clear
        countLabel.translatesAutoresizingMaskIntoConstraints = true
        countLabel.frame = .init(x: 20, y: 0, width: 80, height: 40)
        tableHeaderView = countLabel
        tableFooterView = UIView()
        delegate = self
        separatorInset = .init(top: 0, left: 45, bottom: 0, right: 0)
        separatorColor = UIColor.appTitle.withAlphaComponent(0.2)

        recentSearches = readRecentSearches()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func readRecentSearches() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "rt_recent_searches")
            .map { $0.uniqued() } ?? []
    }

    private func storeRecentSearches(queries: [String]) {
        var croppedQueries = queries
        if queries.count > 20 {
            _ = croppedQueries.popLast()
        }
        UserDefaults.standard.set(croppedQueries, forKey: "rt_recent_searches")
        recentSearches = croppedQueries
    }

    func storeRecentSearch(query: String) {
        recentSearches.removeAll(where: { $0 == query })
        recentSearches.insert(query, at: 0)
        storeRecentSearches(queries: recentSearches)
    }

    func updateResults(results: [RTSearchResult], forQuery query: String) {
        self.results = results
        dataSource = resultsDataSource
        var snapshot = ResultsSnapshot()
        snapshot.appendSections([.results])
        snapshot.appendItems(results)
        resultsDataSource?.apply(snapshot, animatingDifferences: false)

        if results.isEmpty {
            if query.isEmpty {
                loadRecentSearches()
            } else {
                backgroundView = notFoundLabel
                notFoundLabel.centerX(view: self).height(50)
                countLabel.text = nil
            }
        } else {
            countLabel.text = "\(results.count) \(results.count == 1 ? "resultado" : "resultados")"
            backgroundView = UIView()
        }
    }

    func loadRecentSearches() {
        countLabel.text = "Buscas recentes"
        backgroundView = UIView()
        dataSource = recentsDataSource
        var snapshot = RecentsSnapshot()
        snapshot.appendSections([.recents])
        snapshot.appendItems(recentSearches)
        recentsDataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func buildOccurrenceCell(tableView: UITableView, result: RTSearchResult) -> RTSearchResultOccurrenceTableCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: RTSearchResultOccurrenceTableCell.identifier) as? RTSearchResultOccurrenceTableCell
        if result.occurrence != nil {
            cell?.configure(with: result)
        }
        return cell
    }

    private func buildTeamCell(tableView: UITableView, result: RTSearchResult) -> RTSearchResultTeamTableCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: RTSearchResultTeamTableCell.identifier) as? RTSearchResultTeamTableCell
        if result.team != nil {
            cell?.configure(with: result)
        }
        return cell
    }

    private func makeResultsDataSource() -> ResultsDataSource {
        ResultsDataSource(
            tableView: self,
            cellProvider: { (tableView, _, searchResult) -> UITableViewCell? in
                switch searchResult.type {
                case .occurrence:
                    return self.buildOccurrenceCell(tableView: tableView, result: searchResult)
                case .team:
                    return self.buildTeamCell(tableView: tableView, result: searchResult)
                }
            }
        )
    }

    private func makeRecentsDataSource() -> RecentsDataSource {
        RecentsDataSource(
            tableView: self,
            cellProvider: { (tableView, _, recentQuery) -> UITableViewCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: RTRecentSearchCell.identifier) as? RTRecentSearchCell
                cell?.configure(with: recentQuery)
                return cell
            }
        )
    }

    override func didMoveToSuperview() {
        loadRecentSearches()
    }
}

extension RTSearchResultsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = dataSource?.tableView(tableView, cellForRowAt: indexPath) else { return }
        if cell is RTSearchResultTeamTableCell,
           let team = results[indexPath.row].team {
            resultsDelegate?.didSelectATeamResult(team)
        } else if cell is RTSearchResultOccurrenceTableCell,
                  let occurrence = results[indexPath.row].occurrence {
            resultsDelegate?.didSelectAnOccurrenceResult(occurrence)
        } else if cell is RTRecentSearchCell {
            let query = recentSearches[indexPath.row]
            resultsDelegate?.didSelectARecentSearch(query)
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = dataSource?.tableView(tableView, cellForRowAt: indexPath) else { return indexPath }
        cell.contentView.alpha = 0.8
        return indexPath
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = dataSource?.tableView(tableView, cellForRowAt: indexPath) else { return }
        cell.contentView.alpha = 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = dataSource?.tableView(tableView, cellForRowAt: indexPath) else { return 0 }
        if cell is RTSearchResultTeamTableCell {
            return 55
        } else if cell is RTSearchResultOccurrenceTableCell {
            return 70
        } else if cell is RTRecentSearchCell {
            return 40
        }
        return 0
    }
}
