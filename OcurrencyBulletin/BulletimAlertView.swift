//
//  BulletimAlertView.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 25/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletimAlertView: UIView {

    private var label: UILabel = {
        let label = UILabel()
        let mutableString = NSMutableAttributedString()

        let boldText = NSAttributedString(string: "ATENÇÃO: ",
                                          attributes: [
                                            NSAttributedString.Key.font: UIFont.robotoMedium.withSize(14),
                                            NSAttributedString.Key.foregroundColor: UIColor.white
        ])

        let normalText = NSAttributedString(string: "Os dados da ocorrência retratam o momento do registro.", attributes: [
            NSAttributedString.Key.font: UIFont.robotoItalic.withSize(14),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])

        mutableString.append(boldText)
        mutableString.append(normalText)
        label.attributedText = mutableString
        label.enableAutoLayout()
        label.numberOfLines = 0
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(label)
        label.enableAutoLayout()
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            label.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: label.trailingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1)
        ])
        backgroundColor = .appWarning
        layer.cornerRadius = 8
    }
}
