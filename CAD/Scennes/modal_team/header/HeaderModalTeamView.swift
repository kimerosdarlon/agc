//
//  HeaderModalTeam.swift
//  CAD
//
//  Created by Ramires Moreira on 08/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
import HGRippleRadarView

class HeaderModalTeamView: UIView {

    override var intrinsicContentSize: CGSize {
        return .init(width: 100, height: 90)
    }

    var tilteLabel: UILabel = {
        return UILabel(text: "Agente de Campo")
            .font(UIFont.firaSansBoldItalic.withSize(17))
            .color(.appTitle)
    }()

    var statusLabel: UILabel = {
        return UILabel(text: "você está em uma equipe ativa")
            .font(UIFont.firaSansBoldItalic.withSize(13))
            .color(.systemGreen)
    }()

    var logoImage: UIImageView = {
        let imageView = UIImageView().enableAutoLayout().width(52).height(52)
        imageView.image = UIImage(named: "logo_default")!
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var rippleView: RippleView = {
        let radar = RippleView(frame: .init(x: 0, y: 0, width: 30, height: 30))
        radar.diskColor = .systemGreen
        radar.diskRadius = 5
        radar.numberOfCircles = 3
        radar.animationDuration = 0.8
        radar.circleOnColor = .green
        radar.circleOffColor = .appBackground
        radar.paddingBetweenCircles = 3
        return radar
    }()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        backgroundColor = .appBackground

        let builder = GenericDetailBuilder()
        let contentView = builder.verticalStack(spacing: 10, alignment: .center, distribution: .fill).enableAutoLayout()

        let topStack = builder.horizontalStack(alignment: .center)
        topStack.addArrangedSubviewList(views: logoImage, tilteLabel)
        contentView.addArrangedSubview(topStack)
        contentView.setCustomSpacing(16, after: topStack)

        let statusLine = builder.line(views: rippleView, statusLabel, spacing: 12, alignment: .center )
        contentView.addArrangedSubview( statusLine )

        addSubview(contentView)
        contentView.top(mutiplier: 1).centerX()
        bottom(to: contentView.bottomAnchor, 1)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        rippleView.circleOffColor = .appBackground
    }
}
