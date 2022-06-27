//
//  FinishReasonTableCell.swift
//  CAD
//
//  Created by Samir Chaves on 02/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class FinishReasonTableCell: UITableViewCell {
    static let identifier = String(describing: IntermediatePlaceTableCell.self)

    private let nameLabel = UILabel.build(withSize: 14, color: .appTitle)
    private let checkbox = Checkbox(style: .rounded).enableAutoLayout()
    private let inputText: UITextField = {
        let textField = UITextField().enableAutoLayout()
        textField.backgroundColor = .appBackgroundCell
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        textField.layer.cornerRadius = 5
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.isHidden = true
        textField.placeholder = "Descreva aqui..."
        return textField
    }()

    private var labelWidthConstraint: NSLayoutConstraint?

    override func didMoveToSuperview() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        addSubview(nameLabel)
        addSubview(inputText)
        addSubview(checkbox)

        checkbox.isChecked = false
        checkbox.width(20).height(20)
        inputText.height(40)

        labelWidthConstraint = nameLabel.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0)
        labelWidthConstraint?.isActive = true

        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkbox.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 15),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            inputText.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
            inputText.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputText.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
        ])
    }

    func configure(name: String, checked: Bool = false, requiresDescription: Bool = false, description: String? = nil) {
        nameLabel.text = name
        checkbox.isChecked = checked
        labelWidthConstraint?.constant = name.width(withConstrainedHeight: 50, font: UIFont.systemFont(ofSize: 14)) + 10
        if requiresDescription && checked {
            inputText.isHidden = false
            inputText.text = description
        } else {
            inputText.isHidden = true
        }
        layoutIfNeeded()
    }

    func check() {
        checkbox.isChecked = true
    }

    func getDescription() -> String? {
        return inputText.text
    }

    func focusOnDescriptionField() {
        inputText.becomeFirstResponder()
    }
}
