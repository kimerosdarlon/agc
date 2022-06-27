//
//  EquipmentPickerHeaderView.swift
//  CAD
//
//  Created by Samir Chaves on 02/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class EquipmentPickerSectionHeaderView: UITableViewHeaderFooterView {
    private let label = UILabel.build(withSize: 16, color: .appTitle)
    private let filledBadge: UIView = {
        let view = UIView(frame: .zero)
        view.layer.cornerRadius = 6
        view.backgroundColor = .appBlue
        view.contentMode = .scaleAspectFit
        return view.enableAutoLayout()
    }()
    private let iconView: UIImageView = {
        let view = UIImageView()
        return view.enableAutoLayout()
    }()

    var isFilled: Bool = false {
        didSet {
            filledBadge.isHidden = !isFilled
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        contentView.addSubview(label)
        contentView.addSubview(filledBadge)
        contentView.addSubview(iconView)
        backgroundColor = .appBackground
        contentView.backgroundColor = .appBackground
        backgroundView?.backgroundColor = .clear

        let padding: CGFloat = 15

        iconView.height(20)
        iconView.width(20)

        filledBadge.height(12)
        filledBadge.width(12)

        isFilled = false

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            filledBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            filledBadge.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: filledBadge.leadingAnchor, constant: -padding)
        ])
    }

    func configure(with group: EquipmentGroup) {
        label.text = "\(group.name) (\(group.equipments.count))"
        iconView.image = group.image
    }
}
