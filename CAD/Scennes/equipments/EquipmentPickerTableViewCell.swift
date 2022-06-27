//
//  EquipmentPickerTableViewCell.swift
//  CAD
//
//  Created by Samir Chaves on 02/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class EquipmentPickerTableViewCell: UITableViewCell {
    static let identifier = String(describing: EquipmentPickerTableViewCell.self)
    private let checkbox = Checkbox(style: .rounded)
    private let label = UILabel.build(withSize: 16, color: .appTitle)

    override func didMoveToSuperview() {
        addSubview(checkbox)
        addSubview(label)
        backgroundColor = .clear
        checkbox.enableAutoLayout()
        checkbox.height(20)
        checkbox.width(20)
        checkbox.isChecked = false

        let padding: CGFloat = 15

        label.alpha = 0.7

        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding + 10),
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),

            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: padding),
            label.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }

    func configure(with equipment: Equipment) {
        label.text = String.interpolateString(
            values: [equipment.brand, equipment.model, equipment.prefix, equipment.plate],
            separators: [" / ", " - ", " - "]
        )
    }

    func check() {
        checkbox.isChecked = true
        label.alpha = 1
    }

    func uncheck() {
        checkbox.isChecked = false
        label.alpha = 0.7
    }
}
