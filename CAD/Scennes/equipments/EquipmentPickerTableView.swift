//
//  EquipmentPickerTableView.swift
//  CAD
//
//  Created by Samir Chaves on 02/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class EquipmentPickerTableView: UITableView {
    private var groupsSections = [EquipmentGroupSection]()

    typealias TableCell = EquipmentPickerTableViewCell
    typealias DataSource = UITableViewDiffableDataSource<EquipmentGroupSection, EquipmentModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<EquipmentGroupSection, EquipmentModel>
    private var equipmentsDataSource: DataSource?
    private var equipments = [Equipment]()
    var selectedEquipment: Equipment?

    init(equipmentsViewModel: EquipmentGroupViewModel) {
        super.init(frame: .zero, style: .plain)
        equipmentsDataSource = makeDataSource()
        register(TableCell.self, forCellReuseIdentifier: TableCell.identifier)
        updateEquipmentsModel(equipmentsViewModel)
        dataSource = self.equipmentsDataSource
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
    }

    func apply(animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(groupsSections)
        groupsSections.forEach { groupSection in
            if groupSection.isExpanded {
                snapshot.appendItems(groupSection.equipments, toSection: groupSection)
            }
        }
        equipmentsDataSource?.apply(snapshot, animatingDifferences: animated)
    }

    private func makeDataSource() -> DataSource {
        DataSource(
            tableView: self,
            cellProvider: { (tableView, indexPath, equipmentModel) -> TableCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.identifier, for: indexPath) as? TableCell
                cell?.configure(with: equipmentModel.equipment)
                cell?.selectionStyle = .none

                if equipmentModel.isSelected {
                    cell?.check()
                } else {
                    cell?.uncheck()
                }
                return cell
            }
        )
    }

    func selectEquipment(id: UUID) {
        selectedEquipment = equipments.first(where: { $0.id == id })
        groupsSections = groupsSections.map { $0.selectEquipment(id: id) }
        apply(animated: false)
    }

    func updateEquipmentsModel(_ equipmentsModel: EquipmentGroupViewModel) {
        equipments = equipmentsModel.equipments
        self.groupsSections = equipmentsModel.groups.map { group in
            let headerView = EquipmentPickerSectionHeaderView()
            return EquipmentGroupSection(
                isExpanded: true,
                group: group,
                view: headerView
            )
        }
        apply(animated: false)
    }
}

extension EquipmentPickerTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let selectedGroupSection = groupsSections[section]
        let group = selectedGroupSection.group
        let headerView = selectedGroupSection.view
        headerView.tag = section
        headerView.onTap = {
            self.groupsSections = self.groupsSections.map { groupSection in
                if groupSection == selectedGroupSection && !groupSection.isExpanded {
                    return groupSection.expand()
                } else {
                    return groupSection.collapse()
                }
            }
            self.apply()
        }
        headerView.configure(with: group)
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGroupSection = groupsSections[indexPath.section]
        let equipmentModel = selectedGroupSection.equipments[indexPath.row]
        let equipment = equipmentModel.equipment
        if equipmentModel.isSelected {
            groupsSections = groupsSections.map { $0.unselectEquipments() }
            selectedEquipment = nil
        } else {
            groupsSections = groupsSections.map { groupSection in
                if selectedGroupSection == groupSection {
                    return groupSection.selectEquipment(id: equipment.id)
                } else {
                    return groupSection.unselectEquipments()
                }
            }
            selectedEquipment = equipment
        }
        apply(animated: false)
    }
}
