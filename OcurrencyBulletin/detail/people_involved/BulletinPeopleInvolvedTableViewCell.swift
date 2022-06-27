//
//  BulletinPeopleInvolvedTableViewCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 17/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletinPeopleInvolvedTableViewCell: UITableViewCell {
    static let identifier = String(describing: BulletinPeopleInvolvedTableViewCell.self)
    var container: UIStackView?
    private let builder = GenericDetailBuilder()

    fileprivate func getInVolmentsLabels(_ builder: GenericDetailBuilder, _ person: PersonInvolvedDetail) -> UIStackView {
        let lineInvolvments = builder.verticalStack()
        for involvment in person.involvements {
            let nature = builder.buildRoundedLabel(involvment.nature)
            lineInvolvments.addArrangedSubviewList(views: nature, .spacer())
        }
        return lineInvolvments
    }

    func configure(personInvolved person: PersonInvolvedDetail, model: OcurrencyBulletinDetailViewModel) {
        selectionStyle = .none
        backgroundColor = .appBackgroundCell
        builder.configurations.detailLabelBackgroundColor = .appBackgroundCell
        container = builder.verticalStack()
        let natureStack = buildNatureStack(builder, person)

        container?.addArrangedSubviewList(
            views: builder.labelRegular(with: model.getName(person), size: 18, color: .appCellLabel, hasInteraction: model.getName(person) != model.emptyMessage ),
            builder.labelRegular(with: "Suposto Autor/Infrator", size: 16),
            natureStack,
            builder.line(
                views: builder.titleDetail(title: "Nome Social", detail: model.getSocialName(person), linesDetail: 0, hasInteraction: model.getSocialName(person) != model.emptyMessage ),
                builder.titleDetail(title: "Alcunha", detail: model.getNickName(person),
                                    hasInteraction: model.getNickName(person) != model.emptyMessage ),
                distribuition: .fillEqually
            ),
            builder.line(
                views: builder.titleDetail(title: "CPF", detail: model.getCPF(person), linesDetail: 1,
                                           hasInteraction: model.getCPF(person) != model.emptyMessage ),
                builder.titleDetail(title: "Idade", detail: model.getAge(person), linesDetail: 1),
                distribuition: .fillEqually
            ),
            builder.line(
                views: builder.titleDetail(title: "Nome da Mãe", detail: model.getMotherName(person), linesDetail: 0, hasInteraction: model.getMotherName(person) != model.emptyMessage ),
                builder.titleDetail(title: "Nome do Pai", detail: model.getFatherName(person), linesDetail: 0, hasInteraction: model.getFatherName(person) != model.emptyMessage),
                distribuition: .fillEqually
            ),
            builder.line(
                views: builder.titleDetail(title: "Orientação Sexual", detail: model.getSexualOrientation(person)),
                builder.titleDetail(title: "Identidade de Gênero", detail: model.getGender(person)),
                distribuition: .fillEqually
            ),
            builder.line(
                views: builder.titleDetail(title: "Nacionalidade", detail: model.getNationality(person)),
                builder.titleDetail(title: "Naturalidade", detail: person.address?.city ?? "---" ),
                distribuition: .fillEqually
            )
        )
        let hasDocument = !person.documents.isEmpty
        container?.addArrangedSubviewIf(hasDocument, getDocumentsStack(person, builder))
        container?.addArrangedSubview(builder.titleDetail(title: "Profissão", detail: model.getJob(person)))
        let canSeeAddress = UserService.shared.getCurrentUser()?.has(role: Roles.visualizarEnderecosEnvolvidos) ?? false
        container?.addArrangedSubviewIf(canSeeAddress, builder.titleDetail(title: "Endereço", detail: model.getAddress(person), hasInteraction: model.getAddress(person) != model.emptyMessage, hasMapInteraction: true ))
        addSubview(container!)
        container!.enableAutoLayout()
        container!.fillSuperView(regardSafeArea: true)
    }

    private func buildNatureStack(_ builder: GenericDetailBuilder, _ person: PersonInvolvedDetail) -> UIView {
        //        let collection = QualificationCollectionView(qualification: person.involvements.map({$0.nature}))
        //        collection.enableAutoLayout().height(35)
        let natures = person.involvements.map({$0.nature})
        let naturesLabel = natures.map({ builder.buildRoundedLabel($0, color: .appBlue) })
        let natureStack = builder.verticalStack(alignment: .leading, distribution: .fill)
        natureStack.addArrangedSubviewList(views: naturesLabel)
        return natureStack
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        container?.removeFromSuperview()
        container = nil
    }

    func getDocumentsStack(_ person: PersonInvolvedDetail, _ builder: GenericDetailBuilder) -> UIStackView {
        let content = builder.verticalStack()
        let documents = person.documents
        content.addArrangedSubview(
            builder.line(
                views: builder.labelBold(with: "Tipo de Documento"),
                builder.labelBold(with: "Número"),
                distribuition: .fillEqually)
        )
        for document in documents {
            content.addArrangedSubview(
                builder.line(
                    views: builder.labelRegular(with: document.type),
                    builder.labelRegular(with: document.number ?? "---"),
                    distribuition: .fillEqually)
            )
        }
        return content
    }
}
