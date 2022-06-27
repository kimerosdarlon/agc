//
//  OccurrenceTableCellView.swift
//  CAD
//
//  Created by Samir Chaves on 11/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

protocol RecentOccurrenceCellDelegate: class {
    func didTapZoom(to occurrence: SimpleOccurrence)
}

class RecentOccurrenceTableViewCell: MyCustomCell<SimpleOccurrence> {
    weak var delegate: RecentOccurrenceCellDelegate?

    static let identifier = String(describing: RecentOccurrenceTableViewCell.self)

    @domainServiceInject
    private var domainService: DomainService

    private var occurrence: SimpleOccurrence?
    private let container = UIView(frame: .zero).enableAutoLayout()
    private let timeLabel = UILabel.build(withSize: 12, alpha: 0.7, alignment: .left)
    private var priorityLabel = OccurrencePriorityLabel()
    private let addressLabel = UILabel.build(withSize: 15)
    private var naturesTags = ColoredTagGroupView(tags: [], containerBackground: .transparent).enableAutoLayout().height(30)
    private let teamsImage = UIImageView(
        image: UIImage(systemName: "person.3.fill")?
            .withTintColor(UIColor.appTitle.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
    ).enableAutoLayout().height(18).width(32)
    private let teamsLabel = UILabel.build(withSize: 14, alpha: 0.7)
    private let complementaryImage = UIImageView(
        image: UIImage(systemName: "link")?
            .withTintColor(UIColor.appTitle.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
    ).enableAutoLayout().height(18).width(18)
    private let complementaryLabel = UILabel.build(withSize: 14, alpha: 0.7)
    private let operatingRegionLabel: UILabel = {
        let label = UILabel.build(withSize: 13, alpha: 0.5, color: .appCellLabel)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.appCellLabel.cgColor
        label.layer.cornerRadius = 3
        return label
    }()
    private let teamsNameLabel = UILabel.build(withSize: 13, alpha: 0.7)
    private let zoomButton: UIButton = {
        let image = UIImage(named: "target")
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.layer.cornerRadius = 10
        btn.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        btn.backgroundColor = UIColor.appTitle.withAlphaComponent(0.1)
        btn.isUserInteractionEnabled = true
        return btn.enableAutoLayout()
    }()
    private let highlightBar: UIView = {
        let view = UIView().enableAutoLayout()
        view.backgroundColor = .appRedAlert
        return view
    }()
    private let generalAlertIcon: UILabel = {
        let label = UILabel.build(withSize: 9, weight: .bold, color: .appBackground, alignment: .center, text: "!")
        label.layer.cornerRadius = 5.5
        label.backgroundColor = .appRedAlert
        label.layer.masksToBounds = true
        return label
    }()
    private let pulseIcon: UIView = {
        let view = UIView().enableAutoLayout()
        view.layer.cornerRadius = 5.5
        view.backgroundColor = .appRedAlert
        view.alpha = 0.8
        return view
    }()

    @objc private func handleTapInZoom() {
        if let occurrence = occurrence {
            delegate?.didTapZoom(to: occurrence)
        }
    }

    private func getServiceRegisterText(_ serviceRegisteredAt: DateTimeWithTimeZone) -> NSAttributedString {
        let formattedDatetime = serviceRegisteredAt.format()
        let title = NSAttributedString(string: "Registrado: ", attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
        let value = NSAttributedString(string: formattedDatetime, attributes: [.font: UIFont.systemFont(ofSize: 12)])
        let text = NSMutableAttributedString(attributedString: title)
        text.append(value)
        return text
    }

    override func configure(using model: SimpleOccurrence) {
        let serviceRegisterDatetime = model.serviceRegisteredAt.toDate(format: "yyyy-MM-dd'T'HH:mm:ss")
        timeLabel.text = serviceRegisterDatetime?
            .difference(to: Date(), [.year, .month, .day, .hour, .minute])
            .simpleHumanize(date: serviceRegisterDatetime ?? Date())
        let natures = model.natures.map { nature -> ColoredTagGroupView.ColoredTag in
            if let natureGroup = domainService.getGroupByNature(nature.name),
               natureGroup == "Violência Doméstica" {
                return ColoredTagGroupView.ColoredTag(label: nature.name, color: .appPurple)
            }
            
            return ColoredTagGroupView.ColoredTag(label: nature.name, color: .appBlue)
        }
        naturesTags.setTags(natures)
        let address = model.address
        addressLabel.text = address.getFormattedAddress()
        priorityLabel = priorityLabel.withPriority(model.priority)
        teamsLabel.text = "\(model.allocatedTeams.count)"
        occurrence = model
        var teamsCount = ""
        if model.allocatedTeams.count > 1 {
            teamsCount = " (+\(model.allocatedTeams.count))"
        }
        teamsNameLabel.text = (model.allocatedTeams.first?.name).map { "\($0) \(teamsCount)" } ?? "Sem equipes"
        complementaryLabel.text = "\(model.complementaryNumber)"
        operatingRegionLabel.text = "  \(model.operatingRegion.initials) / \(model.operatingRegion.agency.initials)  "

        self.pulseIcon.transform = CGAffineTransform.identity
        self.pulseIcon.alpha = 0.8

        // Pulse animation
        if !self.pulseIcon.isAnimating {
            let timingFunction = CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1) // easeOutCubic
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(timingFunction)
            UIView.animate(withDuration: 2, delay: 0, options: [.repeat]) {
                self.pulseIcon.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 3)
                self.pulseIcon.alpha = 0
            }
            CATransaction.commit()
        }

        if model.generalAlert {
            highlightBar.isHidden = false
            pulseIcon.isHidden = false
            generalAlertIcon.isHidden = false
        } else {
            highlightBar.isHidden = true
            pulseIcon.isHidden = true
            generalAlertIcon.isHidden = true
        }
    }

    override func didMoveToSuperview() {
        contentView.frame = contentView.frame.inset(by: .init(top: 0, left: 0, bottom: 10, right: 0))
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        addSubview(container)
        container.addSubview(timeLabel)
        container.addSubview(priorityLabel)
        container.addSubview(addressLabel)
        container.addSubview(highlightBar)
        container.addSubview(naturesTags)
        container.addSubview(teamsImage)
        container.addSubview(teamsNameLabel)
        container.addSubview(complementaryImage)
        container.addSubview(complementaryLabel)
        container.addSubview(operatingRegionLabel)
        container.addSubview(zoomButton)
        container.addSubview(pulseIcon)
        container.addSubview(generalAlertIcon)
        zoomButton.addTarget(self, action: #selector(handleTapInZoom), for: .touchUpInside)
        naturesTags.isUserInteractionEnabled = false

        selectionStyle = .none

        setupLayout()
    }

    private func setupLayout() {
        let padding: CGFloat = 11

        container.frame = container.frame.inset(by: .init(top: 0, left: 0, bottom: padding, right: 0))
        zoomButton.width(40).height(40)
        operatingRegionLabel.height(23)
        highlightBar.width(3)
        generalAlertIcon.width(11).height(11)
        pulseIcon.width(11).height(11)
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            timeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),

            priorityLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            priorityLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            generalAlertIcon.centerYAnchor.constraint(equalTo: priorityLabel.centerYAnchor),
            generalAlertIcon.leadingAnchor.constraint(equalTo: priorityLabel.trailingAnchor, constant: padding),

            pulseIcon.centerYAnchor.constraint(equalTo: generalAlertIcon.centerYAnchor),
            pulseIcon.centerXAnchor.constraint(equalTo: generalAlertIcon.centerXAnchor),

            naturesTags.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: padding),
            naturesTags.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
            naturesTags.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            addressLabel.topAnchor.constraint(equalTo: naturesTags.bottomAnchor, constant: padding),
            addressLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            addressLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),

            operatingRegionLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: padding),
            operatingRegionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),

            teamsImage.centerYAnchor.constraint(equalTo: teamsNameLabel.centerYAnchor),
            teamsImage.leadingAnchor.constraint(equalTo: operatingRegionLabel.leadingAnchor),

            teamsNameLabel.topAnchor.constraint(equalTo: operatingRegionLabel.bottomAnchor, constant: padding),
            teamsNameLabel.leadingAnchor.constraint(equalTo: teamsImage.trailingAnchor, constant: 5),
            teamsNameLabel.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: padding),
            teamsNameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),

            complementaryImage.centerYAnchor.constraint(equalTo: teamsImage.centerYAnchor),
            complementaryImage.leadingAnchor.constraint(equalTo: teamsNameLabel.trailingAnchor, constant: padding),

            complementaryLabel.centerYAnchor.constraint(equalTo: complementaryImage.centerYAnchor),
            complementaryLabel.leadingAnchor.constraint(equalTo: complementaryImage.trailingAnchor, constant: 5),
            complementaryLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),

            zoomButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
            zoomButton.bottomAnchor.constraint(equalTo: teamsImage.bottomAnchor),

            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),

            highlightBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            highlightBar.topAnchor.constraint(equalTo: topAnchor),
            highlightBar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
