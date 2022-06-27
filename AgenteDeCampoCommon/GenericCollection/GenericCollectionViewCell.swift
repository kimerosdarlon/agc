//
//  GenericCollectionViewCell.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class GenericCollectionViewCell: UICollectionViewCell {

    private let titleLb: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoBold.withSize(12)
        label.textColor = UIColor.appCellLabel
        label.numberOfLines = 0
        return label
    }()

    private let detailLb: UILabel = {
        let label = PaddingLabel(withInsets: 0, 0, 0, 0)
        label.enableAutoLayout()
        label.font = UIFont.robotoRegular.withSize(13)
        label.textColor = UIColor.appCellLabel.withAlphaComponent(0.7)
        label.numberOfLines = 0
        return label
    }()

    private let detailButton: PaddingLabel = {
        let label = PaddingLabel(withInsets: 3, 3, 5, 5)
        label.enableAutoLayout()
        label.font = UIFont.robotoRegular.withSize(13)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()

    private var useButtonOnDetail = false

    public func configure(using item: ItemDetail) {
        titleLb.text = item.title
        if item.detail == nil || item.detail!.isEmpty {
            detailLb.text = "-----"
        } else {
            detailLb.textAlignment = .left
            detailLb.text = item.detail
            if let color = item.detailBackGroundColor {
                useButtonOnDetail = true
                detailButton.backgroundColor = color
                detailButton.text = item.detail
            }
        }
    }

    public override func prepareForReuse() {
        NSLayoutConstraint.deactivate(detailButton.constraints)
        NSLayoutConstraint.deactivate(detailLb.constraints)
        detailButton.removeFromSuperview()
        detailLb.removeFromSuperview()
        layoutSubviews()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(titleLb)
        NSLayoutConstraint.activate([
            titleLb.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            titleLb.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: titleLb.trailingAnchor, multiplier: 1)
        ])

        if useButtonOnDetail {
            addSubview(detailButton)
            detailButton.topAnchor.constraint(equalToSystemSpacingBelow: titleLb.bottomAnchor, multiplier: 1).isActive = true
            detailButton.leadingAnchor.constraint(equalTo: titleLb.leadingAnchor).isActive = true
        } else {
            addSubview(detailLb)
            detailLb.trailingAnchor.constraint(equalTo: titleLb.trailingAnchor).isActive = true
            detailLb.topAnchor.constraint(equalTo: titleLb.bottomAnchor).isActive = true
            detailLb.leadingAnchor.constraint(equalTo: titleLb.leadingAnchor).isActive = true
        }
    }
}
