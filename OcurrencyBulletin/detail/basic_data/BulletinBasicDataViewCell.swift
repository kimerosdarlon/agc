//
//  BulletinBasicDataViewControllerCell.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 03/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletinBasicDataViewCell: MyCustomCell<OcurrencyBulletinDetailViewModel> {

    static let identifier = String(describing: BulletinBasicDataViewCell.self )

    private let builder = GenericDetailBuilder()

    func configureStory(using model: OcurrencyBulletinDetailViewModel) {
        contentView.backgroundColor = .appBackgroundCell
        let builder = GenericDetailBuilder()
        let stoty = builder.titleDetail(title: "Relato", detail: model.story)
        contentView.addSubview(stoty)
        stoty.enableAutoLayout()
        stoty.fillSuperView(regardSafeArea: true)
    }

    override func configure(using model: OcurrencyBulletinDetailViewModel) {
        builder.configurations.detailLabelBackgroundColor = .appBackgroundCell
        selectionStyle = .none
        contentView.backgroundColor = .appBackgroundCell
        let stack = builder.verticalStack(alignment: .fill, distribution: .fill )
        let stateCode = builder.titleDetail(title: "Código Estadual", detail: model.codeState, linesDetail: 1)
        let registryDate = builder.titleDetail(title: "Data de Registro", detail: model.registryDateTime)
        stack.addArrangedSubview( builder.line(views: stateCode, registryDate,
                                               distribuition: .fillEqually, spacing: 16, alignment: .fill))

        stack.addArrangedSubview( builder.titleDetail(title: "Unidade de Registro",
                                                      detail: model.registryPoliceStation) )

        if model.hasResponsiblePoliceStation {
            stack.addArrangedSubview(builder.titleDetail(title: "Unidade de Apuração", detail: model.responsiblePoliceStation))
        }
//        let collection = QualificationCollectionView(qualification: model.nature).enableAutoLayout().height(35)
//        stack.addArrangedSubviewIf(!model.nature.isEmpty, collection)

        let natures = model.nature.map({ builder.buildRoundedLabel($0, color: .appBlue) })
        let natureStack = builder.verticalStack(alignment: .leading, distribution: .fill)
        natureStack.addArrangedSubviewList(views: natures)
        stack.addArrangedSubviewIf(!model.nature.isEmpty, natureStack)

        if model.hasStartDateTime {
            stack.addArrangedSubview(builder.titleDetail(title: "Data da Ocorrência", detail: model.startDateTime))
        }
        if model.hasEndDateTime {
            stack.addArrangedSubview(builder.labelRegular(with: model.endDateTime))
        }
        if model.hasStartDateTime || model.hasStartDateTime {
            addTagsIfNeeded(model, stack, builder)
        }
        stack.addArrangedSubview(builder.titleDetail(title: "Endereço da ocorrência", detail: model.address,
                                                     hasInteraction: model.address != model.emptyMessage, hasMapInteraction: true))
        contentView.addSubview(stack)
        stack.enableAutoLayout()
        stack.fillSuperView(regardSafeArea: true)
    }

    private func addTagsIfNeeded(_ model: OcurrencyBulletinDetailViewModel, _ stack: UIStackView, _ builder: GenericDetailBuilder) {
        var tags = [String]()
        if model.isDateApproximated { tags.append("Data aproximada") }
        if model.isTimeApproximated { tags.append("Hora aproximada") }
        tags.forEach({
            stack.addArrangedSubview(
                builder.verticalStack(alignment: .leading)
                    .addArrangedSubviewList(views: builder.buildRoundedLabel($0, color: .appLightGray))
            )
        })
    }

    override func prepareForReuse() {
        contentView.subviews.forEach({$0.removeFromSuperview()})
    }
}
