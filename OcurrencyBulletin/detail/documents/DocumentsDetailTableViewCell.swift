//
//  DocumentsDetailTableViewCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class DocumentsDetailTableViewCell: UITableViewCell {

    static let identifier = String(describing: DocumentsDetailTableViewCell.self)

    private let builder = GenericDetailBuilder()

    func configure(withDocument document: Documents, andModel model: OcurrencyBulletinDetailViewModel,
                   isExpanded: Bool ) {
        selectionStyle = .none
        builder.configurations.detailLabelBackgroundColor = .appBackgroundCell
        builder.configurations.regularLabelBackgroundColor = .appBackgroundCell
        backgroundColor = .appBackgroundCell
        let stack = buildStack(document: document, model: model).enableAutoLayout()
        addSubview(stack)
        stack.fillSuperView(regardSafeArea: true)
    }

    private func buildStack(document: Documents, model: OcurrencyBulletinDetailViewModel ) -> UIStackView {
        let stack = builder.verticalStack()
        let funcStr = model.string(for:)
        var number = funcStr(document.number)
        var documentType = funcStr(document.type)
        if number.isCPF {
            number = number.applyCpfORCnpjMask
            documentType = "CPF"
        }

        stack.addArrangedSubviewList(
            views: builder.labelRegular(with: documentType, size: 18, color: .appCellLabel),
            builder.titleDetail(title: "Número", detail: number, linesDetail: 0, hasInteraction: number != model.emptyMessage)
        )
//        let collection = QualificationCollectionView(qualification: document.qualifications.reversed(), backGroundCell: .appLightGray).enableAutoLayout().height(35)
        let situation = builder.labelBold(with: "Situação")
        stack.addArrangedSubviewIf(!document.qualifications.isEmpty, situation)
//        stack.addArrangedSubviewIf(!document.qualifications.isEmpty, collection)
        let natures = document.qualifications.reversed().map({ builder.buildRoundedLabel($0, color: .appLightGray) })
        let natureStack = builder.verticalStack(alignment: .leading, distribution: .fillProportionally)
        natureStack.addArrangedSubviewList(views: natures)
        stack.addArrangedSubviewIf(!document.qualifications.isEmpty, natureStack)

        return stack
    }

}
