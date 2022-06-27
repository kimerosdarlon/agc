//
//  VehicleOwnerHeaderView.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 28/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class VehicleOwnerHeaderView: UIView {

    private var ownerNameLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoMedium.withSize(14)
        label.textColor = .appCellLabel
        return label
    }()

    private var addressLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoMedium.withSize(14)
        label.textColor = .appCellLabel
        return label
    }()

    private var alertView: PaddingLabel!

    private var nameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()

    private var addressStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()

    private var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.enableAutoLayout()
        stack.spacing = 16
        return stack
    }()

    func configure(with vehicle: Vehicle) {
        if let name = vehicle.owner?.name, !name.isEmpty {
            ownerNameLb.text = "Propietário:  " + name
            nameStack.addArrangedSubview(ownerNameLb)
            stack.addArrangedSubview(nameStack)
        }

        if let address = vehicle.owner?.address, !address.isEmpty {
            if let alerts = vehicle.alerts {
                if !alerts.isEmpty {
                    addressLb.text = address
                    addressStack.addArrangedSubview(addressLb)
                    stack.addArrangedSubview(addressStack)
                }
            }
        }

        addSubview(stack)
        setupConstraints()
    }

    func setupConstraints() {
        enableAutoLayout()
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 3)
        ])
        height( CGFloat(stack.arrangedSubviews.count) * 40)
        width(frame.width)
        backgroundColor = .appBackgroundCell
    }
}
