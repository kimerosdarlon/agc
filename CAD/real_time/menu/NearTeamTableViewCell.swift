//
//  NearTeamTableViewCell.swift
//  CAD
//
//  Created by Samir Chaves on 12/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class NearTeamTableViewCell: UITableViewCell {
    static var identifier = String(describing: NearTeamTableViewCell.self)

    private let label = UILabel.build(withSize: 14, weight: .bold, color: .appTitle)
    private var operatingRegionsTags = TagGroupView(tags: [], backGroundCell: .clear, containerBackground: .clear, tagBordered: true).enableAutoLayout()
    private let userIcon = UIImageView(image: UIImage(named: "userLight")).enableAutoLayout()
    private let usersCountLabel = UILabel.build(withSize: 14, alpha: 0.5, color: .appTitle)
    private let equipmentIcon = UIImageView(image: UIImage(named: "generalEquipment")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)).enableAutoLayout()
    private let equipmentsCountLabel = UILabel.build(withSize: 14, alpha: 0.5, color: .appTitle)

    override func didMoveToSuperview() {
        let padding: CGFloat = 15

        addSubview(label)
        addSubview(operatingRegionsTags)
        addSubview(userIcon)
        userIcon.width(14).height(14)
        addSubview(usersCountLabel)
        addSubview(equipmentIcon)
        equipmentIcon.width(13).height(14)
        equipmentIcon.alpha = 0.8
        addSubview(equipmentsCountLabel)

        operatingRegionsTags.alpha = 0.6
        operatingRegionsTags.height(35)

        backgroundColor = .clear
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),

            operatingRegionsTags.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            operatingRegionsTags.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            operatingRegionsTags.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            userIcon.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            userIcon.trailingAnchor.constraint(equalTo: usersCountLabel.leadingAnchor, constant: -5),

            usersCountLabel.centerYAnchor.constraint(equalTo: userIcon.centerYAnchor),
            usersCountLabel.trailingAnchor.constraint(equalTo: equipmentIcon.leadingAnchor, constant: -padding),

            equipmentIcon.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            equipmentIcon.trailingAnchor.constraint(equalTo: equipmentsCountLabel.leadingAnchor, constant: -5),

            equipmentsCountLabel.centerYAnchor.constraint(equalTo: equipmentIcon.centerYAnchor),
            equipmentsCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }

    func configure(with team: NonCriticalTeam) {
        label.text = team.name
        let operatingRegions = team.operatingRegions.map { "\($0.initials) / \($0.agency.initials)" }
        operatingRegionsTags.setTags(operatingRegions)
        usersCountLabel.text = "\(team.teamPeople.count)"
        equipmentsCountLabel.text = "\(team.equipments.count)"
    }
}
