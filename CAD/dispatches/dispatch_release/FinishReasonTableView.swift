//
//  FinishReasonTableView.swift
//  CAD
//
//  Created by Samir Chaves on 02/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class FinishReasonViewModel: Hashable {
    let reason: FinishReason
    var selected = false
    var description: String?

    init(reason: FinishReason, selected: Bool = false, description: String? = nil) {
        self.reason = reason
        self.selected = selected
        self.description = description
    }

    static func == (lhs: FinishReasonViewModel, rhs: FinishReasonViewModel) -> Bool {
        lhs.reason.code == rhs.reason.code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(reason.code)
    }
}

class FinishReasonTableView: UITableView {
    enum Section {
        case main
    }

    typealias DataSource = UITableViewDiffableDataSource<Section, FinishReasonViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FinishReasonViewModel>
    private var reasonsDataSource: DataSource?
    private var reasons = [FinishReasonViewModel]()
    var selectedReasonCode: String?
    var selectedReasonDescription: String? {
        guard let selectedReasonIndex = reasons.firstIndex(where: { $0.reason.code == selectedReasonCode }) else { return nil }
        let indexPath = IndexPath(item: selectedReasonIndex, section: 0)
        guard let placeCell = cellForRow(at: indexPath) as? FinishReasonTableCell else { return nil }
        return placeCell.getDescription()
    }

    init(reasons: [FinishReason], selectedReasonCode: String? = nil, selectedReasonDescription: String? = nil) {
        self.reasons = reasons.map { reason in
            if reason.code == selectedReasonCode {
                return FinishReasonViewModel(reason: reason, selected: true, description: selectedReasonDescription)
            } else {
                return FinishReasonViewModel(reason: reason)
            }
        }
        super.init(frame: .zero, style: .plain)
        reasonsDataSource = makeDataSource()
        register(FinishReasonTableCell.self, forCellReuseIdentifier: FinishReasonTableCell.identifier)
        dataSource = self.reasonsDataSource
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
        separatorInset = .zero
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
        reasonsDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func makeDataSource() -> DataSource {
        DataSource(
            tableView: self,
            cellProvider: { (tableView, indexPath, reasonModel) -> FinishReasonTableCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: FinishReasonTableCell.identifier, for: indexPath) as? FinishReasonTableCell
                cell?.configure(name: reasonModel.reason.description,
                                checked: reasonModel.selected,
                                requiresDescription: reasonModel.reason.requiresDescription,
                                description: reasonModel.description)
                cell?.selectionStyle = .none
                return cell
            }
        )
    }
}

extension FinishReasonTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? FinishReasonTableCell
        self.reasons.forEach { $0.selected = false }
        let selectedReason = self.reasons[indexPath.row]
        if selectedReason.reason.requiresDescription {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cell?.focusOnDescriptionField()
            }
        }
        selectedReason.selected = true
        selectedReasonCode = selectedReason.reason.code
        apply()
    }
}
