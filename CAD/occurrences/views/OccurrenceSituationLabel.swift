//
//  OccurrenceSituaitonView.swift
//  CAD
//
//  Created by Samir Chaves on 16/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//
import Foundation
import AgenteDeCampoCommon
import UIKit

class OccurrenceSituationLabel: UIView {

    private var situationIcon: UIImageView = {
        let view = UIImageView(image: nil)
        view.enableAutoLayout().height(13).width(13)
        view.contentMode = .scaleAspectFill
        return view
    }()

    private var situationLabel: UILabel = UILabel.build(withSize: 12)

    func withSituation(_ situation: OccurrenceSituation) -> OccurrenceSituationLabel {
        var situationColor = UIColor.appRed
        var situationIconName = "slash.circle"

        switch situation {
        case .dispatched:
            situationColor = .appGreenMarker
            situationIconName = "car"
        case .dispatchedEnded:
            situationColor = .appGreenMarker
            situationIconName = "checkmark"
        case .notDispatched:
            situationColor = .systemOrange
            situationIconName = "car"
        case .undefinedRegion:
            situationColor = .systemOrange
            situationIconName = "questionmark"
        case .withoutOperator:
            situationColor = .systemOrange
            situationIconName = "minus"
        case .withoutRegion:
            situationColor = .systemOrange
            situationIconName = "minus"
        case .all:
            situationColor = .appBlue
            situationIconName = "circlebadge"
        default:
            situationColor = .appRed
        }

        enableAutoLayout()
        height(15)
        situationIcon.image = UIImage(systemName: situationIconName)?.withTintColor(situationColor, renderingMode: .alwaysOriginal)
        situationLabel.textColor = situationColor
        situationLabel.text = situation.rawValue
        addSubview(situationIcon)
        addSubview(situationLabel)

        NSLayoutConstraint.activate([
            situationIcon.centerYAnchor.constraint(equalTo: situationLabel.centerYAnchor),
            leadingAnchor.constraint(equalTo: situationIcon.leadingAnchor),

            topAnchor.constraint(equalTo: situationLabel.topAnchor),
            situationLabel.leadingAnchor.constraint(equalTo: situationIcon.trailingAnchor, constant: 5),
            bottomAnchor.constraint(equalTo: situationLabel.bottomAnchor),

            situationLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        return self
    }
}
