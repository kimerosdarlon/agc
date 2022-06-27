//
//  StaticSearchResultTableCell.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 21/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public class StaticSearchResultTableCell: UITableViewCell {
    public static let identifier = String(describing: StaticSearchResultTableCell.self)
    private let label = UILabel.build(withSize: 13, color: .appTitle)
    private let selectedIcon = UIImageView(
        image: UIImage(systemName: "checkmark")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
    ).enableAutoLayout()

    public func configure(withValue value: String, isSelected: Bool) {
        label.text = value
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])

        if isSelected {
            addSubview(selectedIcon)
            selectedIcon.width(15).height(15)
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: selectedIcon.leadingAnchor, constant: -10),

                selectedIcon.centerYAnchor.constraint(equalTo: label.centerYAnchor),
                selectedIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            ])

            label.alpha = 0.7
        } else {
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            ])
            label.alpha = 1
        }
        backgroundColor = .clear
    }
}
