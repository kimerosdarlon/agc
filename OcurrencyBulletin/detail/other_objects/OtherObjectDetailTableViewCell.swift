//
//  OtherObjectDetailTableViewCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class OtherObjectDetailTableViewCell: UITableViewCell {

    static let identifier = String(describing: OtherObjectDetailTableViewCell.self)
    private let builder = GenericDetailBuilder()

    func configure(withObject object: BulletinGenericObject, andModel model: OcurrencyBulletinDetailViewModel,
                   isExpanded: Bool ) {
        selectionStyle = .none
        builder.configurations.detailLabelBackgroundColor = .appBackgroundCell
        builder.configurations.regularLabelBackgroundColor = .appBackgroundCell
        backgroundColor = .appBackgroundCell
        let stack = buildStack(object: object, model: model).enableAutoLayout()
        addSubview(stack)
        stack.fillSuperView(regardSafeArea: true)
    }

    private func buildStack(object: BulletinGenericObject, model: OcurrencyBulletinDetailViewModel ) -> UIStackView {
        let stack = builder.verticalStack()
        let funcStr = model.string(for:)
        stack.addArrangedSubview(builder.labelRegular(with: funcStr(object.subgroup), size: 18, color: .appCellLabel))

        stack.addArrangedSubviewIf(!object.qualifications.isEmpty, builder.labelBold(with: "Situação"))
//        let collection = QualificationCollectionView(qualification: object.qualifications.reversed(), backGroundCell: .appLightGray).enableAutoLayout().height(35)
//       stack.addArrangedSubviewIf(!object.qualifications.isEmpty, collection)
        let natures = object.qualifications.reversed().map({ builder.buildRoundedLabel($0, color: .appLightGray) })
        let natureStack = builder.verticalStack(alignment: .leading, distribution: .fillProportionally)
        natureStack.addArrangedSubviewList(views: natures)
        stack.addArrangedSubviewIf(!object.qualifications.isEmpty, natureStack)

        stack.addArrangedSubview(builder.titleDetail(title: "Descrição", detail: funcStr(object.description), linesDetail: 0))
        return stack
    }
}
