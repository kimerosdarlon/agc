//
//  CellphoneDetailTableViewCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class CellphoneDetailTableViewCell: UITableViewCell {
    static let identifier = String(describing: WeaponDetailTableViewCell.self)

    private let builder = GenericDetailBuilder()

    func configure(withCellphone cellPhone: Cellphones, andModel model: OcurrencyBulletinDetailViewModel,
                   isExpanded: Bool ) {
        selectionStyle = .none
        builder.configurations.detailLabelBackgroundColor = .appBackgroundCell
        builder.configurations.regularLabelBackgroundColor = .appBackgroundCell
        contentView.backgroundColor = .appBackgroundCell
        let contentStack = builder.verticalStack(alignment: .center).enableAutoLayout()
        contentView.addSubview(contentStack)
        let weaponStack = buildWeaponStack(cellphone: cellPhone, model: model)
        contentStack.addArrangedSubview(weaponStack)
        let section = builder.headerSection(with: "Proprietário").enableAutoLayout()
        contentStack.addArrangedSubview(section)
        let ownerStack = buildOwnerStack(cellphone: cellPhone, model: model).enableAutoLayout()
        contentStack.addArrangedSubview(ownerStack)

        NSLayoutConstraint.activate([
            section.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            weaponStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            ownerStack.widthAnchor.constraint(equalTo: weaponStack.widthAnchor),
            contentStack.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: contentStack.trailingAnchor, multiplier: 1),
            contentStack.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: contentStack.bottomAnchor, multiplier: 1)
        ])
    }

    private func buildWeaponStack(cellphone: Cellphones, model: OcurrencyBulletinDetailViewModel ) -> UIStackView {
        let stack = builder.verticalStack()
        let funcStr = model.string(for:)

        stack.addArrangedSubview( builder.labelRegular(with: model.phoneHeader(phone: cellphone), size: 18, color: .appCellLabel))
        if cellphone.imeis.count > 0 {
            stack.addArrangedSubview(builder.line(
                views: builder.titleDetail(title: "IMEI", detail: funcStr(cellphone.imei)),
                builder.titleDetail(title: "IMEI2", detail: funcStr(cellphone.imei2)),
                distribuition: .fillEqually
            ))
        }

        if cellphone.imeis.count > 2 {
            stack.addArrangedSubview(builder.line(
                views: builder.titleDetail(title: "IMEI3", detail: funcStr(cellphone.imei3)),
                builder.titleDetail(title: "IMEI4", detail: funcStr(cellphone.imei4)),
                distribuition: .fillEqually
            ))
        }
        stack.addArrangedSubview( builder.titleDetail(title: "Nº série", detail: funcStr(cellphone.serialNumber)))
//        let collection = QualificationCollectionView(qualification: cellphone.qualifications.reversed(), backGroundCell: .appLightGray).enableAutoLayout().height(35)
        stack.addArrangedSubviewIf(!cellphone.qualifications.isEmpty, builder.labelBold(with: "Situação"))
//        stack.addArrangedSubviewIf(!cellphone.qualifications.isEmpty, collection)
        let natures = cellphone.qualifications.reversed().map({ builder.buildRoundedLabel($0, color: .appLightGray) })
        let natureStack = builder.verticalStack(alignment: .leading, distribution: .fillProportionally)
        natureStack.addArrangedSubviewList(views: natures)
        stack.addArrangedSubview(natureStack)
        return stack
    }

    private func buildOwnerStack(cellphone: Cellphones, model: OcurrencyBulletinDetailViewModel) -> UIStackView {
        let ownerStack = builder.verticalStack()
        let funcStr = model.string(for:)
        ownerStack.enableAutoLayout()
        ownerStack.addArrangedSubviewList(
            views: builder.line(
                views: builder.titleDetail(title: "Nome", detail: funcStr(cellphone.owner?.name), linesDetail: 1, hasInteraction: funcStr(cellphone.owner?.name) != model.emptyMessage),
                distribuition: .equalSpacing),
            builder.titleDetail(title: "CPF", detail: model.getCPF(cellphone.owner), hasInteraction: model.getCPF(cellphone.owner) != model.emptyMessage )
        )
        return ownerStack
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach({$0.removeFromSuperview()})
    }
}
