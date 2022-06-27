//
//  ReleaseDescriptionTableCell.swift
//  CAD
//
//  Created by Samir Chaves on 02/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class ReleaseDescriptionTableCell: UITableViewCell {
    static let identifier = String(describing: ReleaseDescriptionTableCell.self)

    private let container = UIView(frame: .zero).enableAutoLayout()
    private let nameLabel = UILabel.build(withSize: 15, color: .appTitle)
    private let checkbox = Checkbox(style: .rounded).enableAutoLayout()

    private var labelWidthConstraint: NSLayoutConstraint?

    override func didMoveToSuperview() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(checkbox)

        container.fillSuperView()

        checkbox.isChecked = false
        checkbox.width(20).height(20)

        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.2).cgColor
        container.layer.cornerRadius = 5

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.95),

            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            checkbox.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    func configure(name: String, checked: Bool = false) {
        nameLabel.text = name
        checkbox.isChecked = checked
        if checked {
            container.backgroundColor = UIColor.appBlue.withAlphaComponent(0.4)
        } else {
            container.backgroundColor = .clear
        }
    }

    func check() {
        checkbox.isChecked = true
    }
}
