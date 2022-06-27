//
//  QualificationCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 02/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class QualificationCell: UICollectionViewCell {

    static let identifier = String(describing: QualificationCell.self)

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
        textLabel.fillSuperView(    )
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
