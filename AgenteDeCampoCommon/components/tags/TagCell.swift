//
//  TagCell.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 08/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class TagCell: UICollectionViewCell {

    public static let identifier = String(describing: TagCell.self)

    public let textLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoMedium.withSize(12)
        label.textColor = .appCellLabel
        label.textAlignment = .center
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
        textLabel.fillSuperView()
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.appCellLabel.cgColor
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        contentView.layer.borderColor = UIColor.appCellLabel.cgColor
    }

    public override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.width = CGFloat(ceilf(Float(size.width)))
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
