//
//  EquipmentCollectionViewCell.swift
//  CAD
//
//  Created by Samir Chaves on 09/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

private let size: CGFloat = 52

class EquipmentCollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: EquipmentCollectionViewCell.self)

    private var equipmentImageContainer: UIView = {
        let container = UIView().height(size).width(size)
        return container
    }()

    private var equipmentImageCircle: UIView = {
        let imageView = UIImageView().height(size / 1.5).width(size / 1.5)
        imageView.backgroundColor = .imageBackGround
        imageView.layer.cornerRadius = (size / 1.5) / 2
        imageView.layer.masksToBounds = true
        return imageView.enableAutoLayout()
    }()

    private var equipmentImageView: UIImageView = {
        let imageView = UIImageView().height(size / 2.7).width(size / 2.7)
        imageView.layer.masksToBounds = true
        return imageView.enableAutoLayout()
    }()

    private var groupName: UILabel = {
        return UILabel()
            .font(UIFont.robotoBold.withSize(14))
            .color(.appCellLabel).lines(0)
    }()

    func configure(with model: EquipmentGroup) {
        equipmentImageView.image = model.image
        groupName.text = "\(model.name) (\(model.equipments.count))"
        contentView.backgroundColor = .memberBackGroundCell
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        equipmentImageContainer.addSubview(equipmentImageView)
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
        equipmentImageView.overrideUserInterfaceStyle = UserStylePreferences.theme.style

        let contentStack = UIStackView().enableAutoLayout()
        contentStack.alignment = .center
        contentStack.spacing = 16

        let labelsStack = UIStackView()
        labelsStack.axis = .vertical
        labelsStack.spacing = 8
        labelsStack.alignment = .leading

        labelsStack.addArrangedSubview(groupName)
        equipmentImageCircle.addSubview(equipmentImageView)
        equipmentImageView.centerX(view: equipmentImageCircle).centerY(view: equipmentImageCircle)
        contentStack.addArrangedSubview(equipmentImageCircle)
        contentStack.addArrangedSubview(labelsStack)

        contentView.addSubview(contentStack)
        contentStack.fillSuperView(regardSafeArea: true)
        contentView.layer.cornerRadius = 8

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        contentView.backgroundColor = .memberBackGroundCell
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        equipmentImageView.image = nil
    }
}
