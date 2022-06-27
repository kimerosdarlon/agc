//
//  ReleaseDescriptionPickerTableView.swift
//  CAD
//
//  Created by Samir Chaves on 02/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class ReleaseReleaseViewModel: Hashable {
    let reason: DispatchReleaseReason
    var selected = false

    init(reason: DispatchReleaseReason, selected: Bool = false) {
        self.reason = reason
        self.selected = selected
    }

    static func == (lhs: ReleaseReleaseViewModel, rhs: ReleaseReleaseViewModel) -> Bool {
        lhs.reason.code == rhs.reason.code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(reason.code)
    }
}

class ReleaseDescriptionPickerTableView: UITableView {
    enum Section {
        case main
    }

    typealias DataSource = UITableViewDiffableDataSource<Section, ReleaseReleaseViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ReleaseReleaseViewModel>
    private var reasonDataSource: DataSource?
    private var reasons = [ReleaseReleaseViewModel]()
    var selectedReason: DispatchReleaseReason?

    init(reasons: [DispatchReleaseReason]) {
        self.reasons = reasons.map { ReleaseReleaseViewModel(reason: $0) }
        super.init(frame: .zero, style: .plain)
        reasonDataSource = makeDataSource()
        register(ReleaseDescriptionTableCell.self, forCellReuseIdentifier: ReleaseDescriptionTableCell.identifier)
        dataSource = self.reasonDataSource
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        tableFooterView = UIView()
        backgroundColor = .appBackground
        layoutMargins = .zero
        separatorInset = .init(top: 5, left: 0, bottom: 0, right: 0)
        separatorStyle = .singleLine
        canCancelContentTouches = false
        delaysContentTouches = false
        isExclusiveTouch = false
        estimatedRowHeight = 80
        rowHeight = UITableView.automaticDimension

        apply()
    }

    private func apply() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.reasons)
        reasonDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func makeDataSource() -> DataSource {
        DataSource(
            tableView: self,
            cellProvider: { (tableView, indexPath, reasonModel) -> ReleaseDescriptionTableCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: ReleaseDescriptionTableCell.identifier, for: indexPath) as? ReleaseDescriptionTableCell
                cell?.configure(name: reasonModel.reason.description, checked: reasonModel.selected)
                cell?.selectionStyle = .none
                return cell
            }
        )
    }
}

extension ReleaseDescriptionPickerTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.reasons.forEach { $0.selected = false }
        let selectedReason = self.reasons[indexPath.row]
        selectedReason.selected = true
        self.selectedReason = selectedReason.reason
        apply()
    }
}
