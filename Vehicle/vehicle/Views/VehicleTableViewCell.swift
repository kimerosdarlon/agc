//
//  VehicleTableViewCell.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 28/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class VehicleTableViewCell: MyCustomCell<VehicleCellViewModel> {

    private var plateView = PlateViewComponent()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoBold.withSize(14)
        label.textColor = .appCellLabel
        label.enableAutoLayout()
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize(14)
        label.textColor = .appCellLabel
        label.enableAutoLayout()
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .appBackground
        contentView.addSubview(plateView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        plateView.left(contentView.safeAreaLayoutGuide.leadingAnchor, mutiplier: 3)
            .centerY().width(100).height(33)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: plateView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: plateView.trailingAnchor, multiplier: 3),
            subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }

    override func configure(using model: VehicleCellViewModel) {
        plateView.set(plate: model.plate)
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }
}
