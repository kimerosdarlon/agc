//
//  PageCell.swift
//  CAD
//
//  Created by Samir Chaves on 09/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class EquipmentCell: UICollectionViewCell {
    private var listBuilder: ListBasedDetailBuilder?
    private var container: UIView?

    private func fillBlankField(_ value: String?) -> String {
        value == nil ? "————" : value!.fillEmpty()
    }

    private func getEquipmentDetails(equipment: Equipment) -> DetailsGroup {
        let items: [InteractableDetailItem?] = [
            InteractableDetailItem(fromItem: (title: "Agência:", detail: "\(equipment.agency.name) - \(equipment.agency.initials)"), hasInteraction: false),
            equipment.brand != nil ? InteractableDetailItem(fromItem: (title: "Marca:", detail: equipment.brand!), hasInteraction: false) : nil,
            equipment.model != nil ? InteractableDetailItem(fromItem: (title: "Modelo:", detail: equipment.model!), hasInteraction: false) : nil,
            InteractableDetailItem(fromItem: (title: "Tipo:", detail: equipment.type.name), hasInteraction: false),
            equipment.prefix != nil ? InteractableDetailItem(fromItem: (title: "Prefixo:", detail: equipment.prefix!), hasInteraction: false) : nil,
            equipment.plate != nil ? InteractableDetailItem(fromItem: (title: "Placa:", detail: equipment.plate!), hasInteraction: false) : nil,
            equipment.km != nil ? InteractableDetailItem(fromItem: (title: "Quilometragem:", detail: String(equipment.km!)), hasInteraction: false) : nil
        ]
        let unwrappedItems = items.compactMap { $0 }
        let groups: [[InteractableDetailItem]] = unwrappedItems.chunked(into: 2)
        return DetailsGroup(items: groups)
    }

    func configure(with equipment: Equipment) {
        container?.removeFromSuperview()
        container = UIView(frame: .zero).enableAutoLayout().fillSuperView()
        addSubview(container!)
        let detailsGroup = getEquipmentDetails(equipment: equipment)
        listBuilder = ListBasedDetailBuilder(
            into: container!,
            padding: .init(top: 5, left: 5, bottom: 5, right: 5),
            spacing: 0.75,
            widthMultiplier: 0.95
        )
        listBuilder?.buildDetailsBlock(DetailsBlock(group: detailsGroup, identifier: equipment.id.uuidString))
        listBuilder?.setupLayout()
    }

    override func didMoveToSuperview() {
        backgroundColor = .appBackground
    }
}
