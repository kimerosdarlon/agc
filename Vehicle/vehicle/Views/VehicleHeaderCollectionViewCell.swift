//
//  VehicleHeaderCollectionViewCell.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class VehicleHeaderCollectionViewCell: UICollectionViewCell {

    private let titleLb: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoBold.withSize(12)
        label.textColor = UIColor.appCellLabel
        label.numberOfLines = 0
        return label
    }()

    private let detailLb: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoRegular.withSize(13)
        label.textColor = UIColor.appCellLabel.withAlphaComponent(0.7)
        label.numberOfLines = 0
        return label
    }()

    func configure(using item: ItemDetail) {
        backgroundColor = .appBackground
        titleLb.text = item.title
        if item.detail == nil || item.detail!.isEmpty {
            detailLb.text = "-----"
        } else {
            detailLb.textAlignment = .left
            if item.title.uppercased().elementsEqual("CHASSI") && item.detail != nil && !item.detail!.isEmpty {
                let chassis = item.detail!
                if chassis.count < 17 {
                    detailLb.text = chassis
                    return
                }
                let textRange = NSRange(location: 0, length: chassis.count )
                let attrRegular = [ NSAttributedString.Key.font: UIFont.robotoRegular.withSize(13) ]
                let attrBold = [NSAttributedString.Key.font: UIFont.robotoBold.withSize(14),
                                .foregroundColor: UIColor.chassisBold]
                let startIndex = chassis.index(chassis.startIndex, offsetBy: 17 - 8)
                let startChassis = chassis[chassis.startIndex..<startIndex]
                let endChassis = chassis[startChassis.endIndex..<chassis.endIndex]
                let firstPart = NSMutableAttributedString(string: String(startChassis), attributes: attrRegular)
                let secondPart = NSMutableAttributedString(string: String(endChassis), attributes: attrBold)
                firstPart.append(secondPart)
                firstPart.addAttribute(NSAttributedString.Key.underlineStyle,
                                           value: NSUnderlineStyle.single.rawValue, range: textRange)
                detailLb.attributedText = firstPart
            } else {
                if let detail = item.detail, item.hasInteraction {
                    let textRange = NSRange(location: 0, length: detail.count )
                    let attributedText = NSMutableAttributedString(string: detail)
                    attributedText.addAttribute(NSAttributedString.Key.underlineStyle,
                                                value: NSUnderlineStyle.single.rawValue, range: textRange)
                    detailLb.attributedText = attributedText
                } else {
                    detailLb.text = item.detail
                }
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(titleLb)
        addSubview(detailLb)
        NSLayoutConstraint.activate([
            titleLb.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            titleLb.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: titleLb.trailingAnchor, multiplier: 1),

            detailLb.topAnchor.constraint(equalTo: titleLb.bottomAnchor),
            detailLb.leadingAnchor.constraint(equalTo: titleLb.leadingAnchor),
            detailLb.trailingAnchor.constraint(equalTo: titleLb.trailingAnchor)

        ])
    }
}

class SectionHeaderView: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoBold.withSize(16)
        label.textColor = UIColor.appCellLabel
        label.enableAutoLayout()
        return label
    }()

    let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize(12)
        label.textColor = UIColor.appCellLabel
        label.enableAutoLayout()
        return label
    }()

    override func layoutSubviews() {
        addSubview(titleLabel)
        addSubview(detailLabel)
        backgroundColor = .appBackgroundCell
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            titleLabel.trailingAnchor.constraint(equalToSystemSpacingAfter: detailLabel.leadingAnchor, multiplier: 2),
            bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
            detailLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: detailLabel.trailingAnchor, multiplier: 1)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        detailLabel.text = ""
    }
}
