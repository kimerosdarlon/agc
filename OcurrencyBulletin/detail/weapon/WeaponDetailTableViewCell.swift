//
//  WeaponDetailTableViewCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class WeaponDetailTableViewCell: UITableViewCell {

    static let identifier = String(describing: WeaponDetailTableViewCell.self)

    private let builder = GenericDetailBuilder()

    func configure(withWeapon weapon: Weapons, andModel model: OcurrencyBulletinDetailViewModel,
                   isExpanded: Bool ) {
        selectionStyle = .none
        builder.configurations.detailLabelBackgroundColor = .appBackgroundCell
        builder.configurations.regularLabelBackgroundColor = .appBackgroundCell
        backgroundColor = .appBackgroundCell
        let contentStack = builder.verticalStack(alignment: .center).enableAutoLayout()
        addSubview(contentStack)
        let weaponStack = buildWeaponStack(weapon: weapon, model: model)
        contentStack.addArrangedSubview(weaponStack)
        let section = builder.headerSection(with: "Proprietário").enableAutoLayout()
        contentStack.addArrangedSubview(section)
        let ownerStack = buildOwnerStack(weapon: weapon, model: model).enableAutoLayout()
        contentStack.addArrangedSubview(ownerStack)

        NSLayoutConstraint.activate([
            section.widthAnchor.constraint(equalTo: widthAnchor),
            weaponStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            ownerStack.widthAnchor.constraint(equalTo: weaponStack.widthAnchor),
            contentStack.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: contentStack.trailingAnchor, multiplier: 1),
            contentStack.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: contentStack.bottomAnchor, multiplier: 1)
        ])
    }

    private func buildWeaponStack(weapon: Weapons, model: OcurrencyBulletinDetailViewModel ) -> UIStackView {
        let stack = builder.verticalStack()

        let funcStr = model.string(for:)
        let model = weapon.model ?? "Modelo não informado"
        let collection = QualificationCollectionView(qualification: weapon.qualifications.reversed(), backGroundCell: .appLightGray)
            .enableAutoLayout().height(35)

        stack.addArrangedSubviewList(
            views: builder.labelRegular(with: model, size: 18, color: .appCellLabel),
            builder.line(
                views: builder.titleDetail(title: "Marca", detail: funcStr(weapon.brand)),
                builder.titleDetail(title: "Calibre", detail: funcStr(weapon.caliberStr)),
                distribuition: .fillEqually
            ),
            builder.line(
                views: builder.titleDetail(title: "Nº identificação", detail: funcStr(weapon.identification), linesDetail: 1),
                builder.titleDetail(title: "Nº Sinarm", detail: funcStr(weapon.sinarmId)),
                distribuition: .fillEqually
            ),
            builder.line(
                views: builder.titleDetail(title: "Fabricação", detail: funcStr(weapon.manufactureOrigin)),
                builder.titleDetail(title: "Uso", detail: funcStr(weapon.usage) ),
                distribuition: .fillEqually
            )
        )
        stack.addArrangedSubviewIf(!weapon.qualifications.isEmpty, builder.labelBold(with: "Situação"))
        stack.addArrangedSubviewIf(!weapon.qualifications.isEmpty, collection)
        return stack
    }

    private func buildOwnerStack(weapon: Weapons, model: OcurrencyBulletinDetailViewModel) -> UIStackView {
        let ownerStack = builder.verticalStack()
        let funcStr = model.string(for:)
        ownerStack.enableAutoLayout()
        ownerStack.addArrangedSubviewList(
            views: builder.line(
                views: builder.titleDetail(title: "Nome", detail: funcStr(weapon.owner?.name), linesDetail: 1, hasInteraction: funcStr(weapon.owner?.name) != model.emptyMessage),
                distribuition: .equalSpacing),
            builder.titleDetail(title: "CPF", detail: model.getCPF(weapon.owner), hasInteraction: model.getCPF(weapon.owner) != model.emptyMessage )
        )
        return ownerStack
    }

}
