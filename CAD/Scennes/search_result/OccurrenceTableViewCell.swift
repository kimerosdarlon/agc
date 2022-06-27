//
//  DriverTableCellView.swift
//  Driver
//
//  Created by Samir Chaves on 28/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class OccurrenceTableViewCell: MyCustomCell<SimpleOccurrence> {

    static let identifier = String(describing: OccurrenceTableViewCell.self)

    private let container = UIView(frame: .zero).enableAutoLayout()
    private let timeLabel = UILabel.build(withSize: 12, alpha: 0.7, alignment: .left)
    private let protocolLabel = UILabel.build(withSize: 14, weight: .bold)
    private let registeredLabel = UILabel.build(withSize: 14, weight: .bold)
    private var situationLabel = OccurrenceSituationLabel()
    private let addressLabel = UILabel.build(withSize: 12, alpha: 0.7)
    private var regionsTags = TagGroupView(tags: [], containerBackground: .transparent, tagBordered: true).enableAutoLayout().height(30)
    private var naturesTags = TagGroupView(tags: []).enableAutoLayout().height(30)
    private let linkIcon = UIImageView(
        image: UIImage(systemName: "link")?
            .withTintColor(UIColor.appTitle.withAlphaComponent(0.7), renderingMode: .alwaysOriginal)
    ).enableAutoLayout().height(18).width(18)

    private func getServiceRegisterText(_ serviceRegisteredAt: DateTimeWithTimeZone) -> NSAttributedString {
        let formattedDatetime = serviceRegisteredAt.format()
        let title = NSAttributedString(string: "Registrado: ", attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
        let value = NSAttributedString(string: formattedDatetime, attributes: [.font: UIFont.systemFont(ofSize: 12)])
        let text = NSMutableAttributedString(attributedString: title)
        text.append(value)
        return text
    }

    override func configure(using model: SimpleOccurrence) {
        let serviceRegisterDatetime = model.serviceRegisteredAt.toDate(format: "yyyy-MM-dd'T'HH:mm:ss", timezoned: false)
        let currentDate = Date().convertToUTC()!
        timeLabel.text = serviceRegisterDatetime?
            .difference(to: currentDate, [.year, .month, .day, .hour, .minute])
            .humanize(shortText: false, rounded: true)
        registeredLabel.attributedText = getServiceRegisterText(model.serviceRegisteredAt)
        regionsTags.setTags(["\(model.operatingRegion.initials) / \(model.operatingRegion.agency.initials)"])
        naturesTags.setTags(model.natures.map { $0.name })
        protocolLabel.text = model.protocol
        let address = model.address
        let formattedAddress = address.getFormattedAddress()
        addressLabel.text = formattedAddress
        situationLabel = situationLabel.withSituation(model.situation)

        linkIcon.isHidden = model.mainOccurrenceId == nil

        setupSubviews()
    }

    func setupSubviews() {
        let padding: CGFloat = 10
        contentView.frame = contentView.frame.inset(by: .init(top: 0, left: 0, bottom: 10, right: 0))
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        addSubview(container)
        container.addSubview(linkIcon)
        container.addSubview(timeLabel)
        container.addSubview(protocolLabel)
        container.addSubview(registeredLabel)
        container.addSubview(situationLabel)
        container.addSubview(addressLabel)
        container.addSubview(regionsTags)
        container.addSubview(naturesTags)
        container.backgroundColor = .appBackgroundCell

        selectionStyle = .none

        container.layer.cornerRadius = 10
        container.frame = container.frame.inset(by: .init(top: 0, left: 0, bottom: padding, right: 0))
        NSLayoutConstraint.activate([
            linkIcon.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            linkIcon.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -padding),

            timeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            timeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),

            situationLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            situationLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            protocolLabel.topAnchor.constraint(equalTo: situationLabel.bottomAnchor, constant: padding),
            protocolLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            registeredLabel.topAnchor.constraint(equalTo: protocolLabel.bottomAnchor, constant: padding),
            registeredLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            addressLabel.topAnchor.constraint(equalTo: registeredLabel.bottomAnchor, constant: padding),
            addressLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            regionsTags.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: padding),
            regionsTags.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
            regionsTags.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            naturesTags.topAnchor.constraint(equalTo: regionsTags.bottomAnchor, constant: padding),
            naturesTags.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
            naturesTags.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
