//
//  BulletinVehicleDetailTableViewCell.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 29/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletinVehicleDetailTableViewCell: UITableViewCell {

    static let identifier = String(describing: BulletinVehicleDetailTableViewCell.self)

    private let builder = GenericDetailBuilder()

    func configure(withVehicle vehicle: VehicleBulletim, andModel model: OcurrencyBulletinDetailViewModel,
                   isExpanded: Bool ) {
        selectionStyle = .none
        builder.configurations.detailLabelBackgroundColor = .appBackgroundCell
        builder.configurations.regularLabelBackgroundColor = .appBackgroundCell
        backgroundColor = .appBackgroundCell
        let contentStack = builder.verticalStack(alignment: .center).enableAutoLayout()
        addSubview(contentStack)
        let vehicleStack = buildVehicleStack(vehicle: vehicle, model: model).enableAutoLayout()
        contentStack.addArrangedSubview(vehicleStack)
        let section = builder.headerSection(with: "Proprietário").enableAutoLayout()
        contentStack.addArrangedSubview(section)
        let ownerStack = buildOwnerStack(vehicle: vehicle, model: model).enableAutoLayout()
        contentStack.addArrangedSubview(ownerStack)

        NSLayoutConstraint.activate([
            section.widthAnchor.constraint(equalTo: widthAnchor),
            vehicleStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            ownerStack.widthAnchor.constraint(equalTo: vehicleStack.widthAnchor),
            contentStack.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: contentStack.trailingAnchor, multiplier: 1),
            contentStack.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: contentStack.bottomAnchor, multiplier: 1)
        ])
    }

    private func buildVehicleStack(vehicle: VehicleBulletim, model: OcurrencyBulletinDetailViewModel ) -> UIStackView {
        let stack = builder.verticalStack()
        let funcStr = model.string(for:)
        stack.addArrangedSubviewList(
            views: builder.labelRegular(with: model.plate(for: vehicle), size: 18, color: .appCellLabel, hasInteraction: model.plate(for: vehicle) != model.emptyMessage ),
            builder.line(
                views: builder.titleDetail(title: "Marca", detail: funcStr(vehicle.brand), linesDetail: 1),
                builder.titleDetail(title: "Modelo", detail: funcStr(vehicle.model)),
                distribuition: .fillEqually),
            builder.line(
                views: builder.titleDetail(title: "Chassis", detail: funcStr(vehicle.chassis), hasInteraction: funcStr(vehicle.chassis) != model.emptyMessage ),
                builder.titleDetail(title: "Cor", detail: funcStr(vehicle.color) ),
                distribuition: .fillEqually)
        )

//        let collection = QualificationCollectionView(qualification: vehicle.qualifications.reversed(), backGroundCell: .appLightGray).enableAutoLayout().height(35)
        stack.addArrangedSubviewIf(!vehicle.qualifications.isEmpty, builder.labelBold(with: "Situação"))
//        stack.addArrangedSubviewIf(!vehicle.qualifications.isEmpty, collection)
        let natures = vehicle.qualifications.reversed().map({ builder.buildRoundedLabel($0, color: .appLightGray) })
        let natureStack = builder.verticalStack(alignment: .leading, distribution: .fill)
        natureStack.addArrangedSubviewList(views: natures)
        stack.addArrangedSubview(natureStack)
        return stack
    }

    private func buildOwnerStack(vehicle: VehicleBulletim, model: OcurrencyBulletinDetailViewModel) -> UIStackView {
        let ownerStack = builder.verticalStack()
        let funcStr = model.string(for:)
        ownerStack.enableAutoLayout()
        ownerStack.addArrangedSubviewList(
            views: builder.line(
                views: builder.titleDetail(title: "Nome", detail: funcStr(vehicle.owner?.name), linesDetail: 1, hasInteraction: funcStr(vehicle.owner?.name) != model.emptyMessage),
                distribuition: .equalSpacing),
            builder.titleDetail(title: "CPF", detail: model.getCPF(vehicle.owner), hasInteraction: model.getCPF(vehicle.owner) != model.emptyMessage )
        )
        return ownerStack
    }

}
