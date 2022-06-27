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
    private let chevron = UIImageView(
        image: UIImage(systemName: "chevron.down")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
    ).enableAutoLayout()

    var isFilled: Bool = false {
        didSet {
            filledBadge.isHidden = !isFilled
        }
    }

    var isExpanded: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isExpanded {
                    self.chevron.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                } else {
                    self.chevron.transform = CGAffineTransform.init(rotationAngle: 0)
                }
            }
        }
    }

    var onTap = { }

    @objc func didTap() {
        onTap()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        contentView.addSubview(label)
        contentView.addSubview(filledBadge)
        contentView.addSubview(iconView)
        contentView.addSubview(chevron)
        backgroundColor = .appBackground
        contentView.backgroundColor = .appBackground
        backgroundView?.backgroundColor = .clear

        let padding: CGFloat = 15

        iconView.height(20)
        iconView.width(20)

        chevron.height(18)
        chevron.width(18)
        chevron.alpha = 0.7

        filledBadge.height(12)
        filledBadge.width(12)

        isFilled = false

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            filledBadge.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -padding),
            filledBadge.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            chevron.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: filledBadge.leadingAnchor, constant: -padding)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapGesture)
    }

    func configure(with group: EquipmentGroup) {
        label.text = "\(group.name) (\(group.equipments.count))"
        iconView.image = group.image
    }
}
