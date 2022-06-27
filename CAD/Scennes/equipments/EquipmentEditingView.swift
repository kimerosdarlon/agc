//
//  EquipmentEditingView.swift
//  CAD
//
//  Created by Samir Chaves on 25/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class EquipmentEditingView: UIView {

    private let modelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTitle
        label.alpha = 0.7
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
        label.font = .systemFont(ofSize: 14)
        label.enableAutoLayout()
        return label
    }()

    private let kmField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.textField.withAlphaComponent(0.1)
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        textField.layer.cornerRadius = 5
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        let unitSuffix = UILabel()
        unitSuffix.textColor = .appTitle
        unitSuffix.alpha = 0.7
        unitSuffix.text = "  Km  "
        unitSuffix.font = .systemFont(ofSize: 14)
        textField.rightView = unitSuffix
        textField.rightViewMode = .always
        textField.enableAutoLayout()
        textField.keyboardType = .decimalPad
        textField.font = UIFont.systemFont(ofSize: 18)
        return textField
    }()

    var onEdit: (String) -> Void = { _ in }

    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.appBackgroundCell.withAlphaComponent(0.5)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubview(modelLabel)
        addSubview(kmField)
    }

    private func setupContraints() {
        kmField.height(40).width(115)

        NSLayoutConstraint.activate([
            modelLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            modelLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            kmField.centerYAnchor.constraint(equalTo: centerYAnchor),
            kmField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }

    private func getModelText(fromEquipment equiment: Equipment) -> NSAttributedString {
        let line1 = [equiment.prefix, equiment.plate].compactMap { $0 }.joined(separator: " | ")
        let line2 = [equiment.model, equiment.brand].compactMap { $0 }.joined(separator: " | ")
        let attrLines = [
            NSAttributedString(string: line1, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)]),
            NSAttributedString(string: line2, attributes: [NSAttributedString.Key.foregroundColor: UIColor.appTitle.withAlphaComponent(0.7)])
        ].filter { $0.string != "" }
        let model = NSMutableAttributedString(attributedString: attrLines.first ?? NSAttributedString())
        if let lastLine = attrLines.last, attrLines.count == 2 {
            model.append(NSAttributedString(string: "\n"))
            model.append(lastLine)
        }
        return model
    }

    func configure(withEquipment equipment: Equipment) {
        modelLabel.attributedText = getModelText(fromEquipment: equipment)
        if let km = equipment.km {
            kmField.text = "\(km)"
        }
        kmField.delegate = self
        enableAutoLayout()
        addSubviews()
        setupContraints()
    }
}

extension EquipmentEditingView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let kmValue = textField.text {
            onEdit(kmValue)
        }
    }
}
