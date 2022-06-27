//
//  DrugsDetailTableViewCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 03/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class DrugsDetailTableViewCell: UITableViewCell {

    static let identifier = String(describing: DrugsDetailTableViewCell.self)
    private let builder = GenericDetailBuilder()

    func configure(withDrugs drugs: Drugs, andModel model: OcurrencyBulletinDetailViewModel,
                   isExpanded: Bool ) {
        selectionStyle = .none
        builder.configurations.detailLabelBackgroundColor = .appBackgroundCell
        builder.configurations.regularLabelBackgroundColor = .appBackgroundCell
        backgroundColor = .appBackgroundCell
        let stack = buildStack(drugs: drugs, model: model).enableAutoLayout()
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: stack.bottomAnchor, multiplier: 1)
        ])
    }

    private func buildStack(drugs: Drugs, model: OcurrencyBulletinDetailViewModel ) -> UIStackView {
        let contentStack = builder.verticalStack(alignment: .center).enableAutoLayout()
        let detailsStack = builder.verticalStack().enableAutoLayout()
        contentStack.addArrangedSubview(detailsStack)
        NSLayoutConstraint.activate([
            detailsStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor, multiplier: 0.95)
        ])
        let funcStr = model.string(for:)
        detailsStack.addArrangedSubview(builder.labelBold(with: funcStr(drugs.description), numberOfLines: 0 ))
        detailsStack.addArrangedSubview(builder.titleDetail(title: "Tipo de embalagem", detail: funcStr(drugs.packing?.name)))
        detailsStack.addArrangedSubview(builder.titleDetail(title: "Localização", detail: funcStr(drugs.location?.name)))
//        let collection = QualificationCollectionView(qualification: drugs.qualifications.reversed(), backGroundCell: .appLightGray).enableAutoLayout().height(35)
        let situation = builder.labelBold(with: "Situação")
        detailsStack.addArrangedSubviewIf(!drugs.qualifications.isEmpty, situation)
//        detailsStack.addArrangedSubviewIf(!drugs.qualifications.isEmpty, collection)

        let natures = drugs.qualifications.reversed().map({ builder.buildRoundedLabel($0, color: .appLightGray) })
        let natureStack = builder.verticalStack(alignment: .leading, distribution: .fill)
        natureStack.addArrangedSubviewList(views: natures)
        detailsStack.addArrangedSubviewIf(!drugs.qualifications.isEmpty, natureStack)

        let involvmentsType = Set<String>.init(drugs.involvements.flatMap({$0.types}))

        for involvment in involvmentsType {
            let header = builder.headerSection(with: involvment).enableAutoLayout()
            contentStack.addArrangedSubview(header)
            header.width(contentStack)
            let personStack = builder.verticalStack().enableAutoLayout()
            let peopleInvolved = drugs.involvements.filter({$0.types.contains(involvment)})
            for person in peopleInvolved {
                guard let personInvolved = model.involveds.first(where: {$0.personId == person.personId})
                    else { continue }
                let document = funcStr(personInvolved.cpf ?? personInvolved.cnpj).applyCpfORCnpjMask
                let name = builder.titleDetail(title: "Nome", detail: funcStr(personInvolved.name) )
                let cpf = builder.titleDetail(title: "CPF/CNPJ", detail: document)
                let line = builder.line(views: name, cpf, distribuition: .fillEqually)
                personStack.addArrangedSubview(line)
            }
            contentStack.addArrangedSubview(personStack)
            NSLayoutConstraint.activate([
                personStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor, multiplier: 0.95)
            ])
        }
        return contentStack
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach({$0.removeFromSuperview()})
    }
}
