//
//  BulletinLegalInvolvedTableViewCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 17/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletinLegalInvolvedTableViewCell: UITableViewCell {

    static let identifier = String(describing: BulletinLegalInvolvedTableViewCell.self)
    var container: UIStackView?
    func configure(personInvolved person: PersonInvolvedDetail, model: OcurrencyBulletinDetailViewModel) {
        backgroundColor = .appBackgroundCell
        let builder = GenericDetailBuilder()
        container = builder.verticalStack()
        container?.addArrangedSubviewList(
            views: builder.titleDetail(title: "Nome Fantasia", detail: model.getName(person), linesDetail: 0 ),
            builder.titleDetail(title: "Razão social", detail: model.getCompanyName(person), linesDetail: 0 ),
            builder.titleDetail(title: "CNPJ", detail: model.getCNPJ(person), linesDetail: 1),
            builder.titleDetail(title: "Representante", detail: model.getRepresentative(person)),
            builder.titleDetail(title: "Ramo de atuação", detail: model.getBusinessLine(person)),
            builder.titleDetail(title: "Endereço", detail: model.getAddress(person))
        )
        addSubview(container!)
        container!.enableAutoLayout()
        container!.fillSuperView(regardSafeArea: true)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        container?.removeFromSuperview()
        container = nil
    }
}
