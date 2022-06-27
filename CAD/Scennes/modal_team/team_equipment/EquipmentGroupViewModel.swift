//
//  EquipmentViewModel.swift
//  CAD
//
//  Created by Samir Chaves on 09/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import UIKit

struct EquipmentGroup: Hashable {
    let name: String
    let equipments: [Equipment]
    let image: UIImage

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    public static func == (lhs: EquipmentGroup, rhs: EquipmentGroup) -> Bool {
        return lhs.name == rhs.name
    }
}

class EquipmentGroupViewModel {
    let equipments: [Equipment]
    var groups = [EquipmentGroup]()

    func getImageName(forGroup groupName: String) -> String {
        switch groupName {
        case "Aeronave":
            return "airplaneEquipment"
        case "Aquáticos":
            return "boatEquipment"
        case "Veículos":
            return "carEquipment"
        case "Equipamento":
            return "generalEquipment"
        case "Viatura":
            return "carEmergencyEquipment"
        case "Animais":
            return "animalEquipment"
        default:
            return "otherEquipment"
        }
    }

    init(equipments: [Equipment]) {
        self.equipments = equipments
        let defaultId = UUID()
        let groupsDict = Dictionary(grouping: equipments, by: { $0.groupEquipment?.id ?? defaultId })
        self.groups = groupsDict.keys.map { key in
            let name = groupsDict[key]?.first?.groupEquipment?.name ?? "Outros"
            return EquipmentGroup(
                name: name,
                equipments: groupsDict[key] ?? [],
                image: UIImage(named: getImageName(forGroup: name))!.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
            )
        }
    }
}
