//
//  EquipmentGroupSection.swift
//  CAD
//
//  Created by Samir Chaves on 08/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

struct EquipmentGroupSection: Hashable {
    var isExpanded: Bool
    let group: EquipmentGroup
    let view: EquipmentPickerSectionHeaderView
    let equipments: [EquipmentModel]

    init(isExpanded: Bool, group: EquipmentGroup, view: EquipmentPickerSectionHeaderView) {
        self.isExpanded = isExpanded
        self.group = group
        self.view = view
        self.view.isExpanded = true
        self.equipments = group.equipments.map {
            EquipmentModel(isSelected: false, equipment: $0)
        }
    }

    private init(isExpanded: Bool,
                 group: EquipmentGroup,
                 view: EquipmentPickerSectionHeaderView,
                 equipments: [EquipmentModel]) {
        self.isExpanded = isExpanded
        self.group = group
        self.view = view
        self.equipments = equipments
    }

    func selectEquipment(id: UUID) -> EquipmentGroupSection {
        view.isFilled = false
        let newEquipments = equipments.map { equipment -> EquipmentModel in
            if equipment.equipment.id == id {
                view.isFilled = true
                return equipment.select()
            } else {
                return equipment.unselect()
            }
        }

        return EquipmentGroupSection(
            isExpanded: isExpanded,
            group: group,
            view: view,
            equipments: newEquipments
        )
    }

    func unselectEquipments() -> EquipmentGroupSection {
        view.isFilled = false
        return EquipmentGroupSection(
            isExpanded: isExpanded,
            group: group,
            view: view,
            equipments: equipments.map { $0.unselect() }
        )
    }

    func expand() -> EquipmentGroupSection {
        view.isExpanded = true
        return EquipmentGroupSection(
            isExpanded: true,
            group: group,
            view: view,
            equipments: equipments
        )
    }

    func collapse() -> EquipmentGroupSection {
        view.isExpanded = false
        return EquipmentGroupSection(
            isExpanded: false,
            group: group,
            view: view,
            equipments: equipments
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(group)
    }

    static func == (lhs: EquipmentGroupSection, rhs: EquipmentGroupSection) -> Bool {
        return lhs.group == rhs.group
    }
}

struct EquipmentModel: Hashable {
    var isSelected: Bool
    let equipment: Equipment

    func select() -> EquipmentModel {
        EquipmentModel(isSelected: true, equipment: equipment)
    }

    func unselect() -> EquipmentModel {
        EquipmentModel(isSelected: false, equipment: equipment)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(equipment)
    }

    static func == (lhs: EquipmentModel, rhs: EquipmentModel) -> Bool {
        return lhs.equipment == rhs.equipment && lhs.isSelected == rhs.isSelected
    }
}
