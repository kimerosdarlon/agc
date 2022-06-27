//
//  WarrantTableViewCell.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 08/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class WarrantTableViewCell: MyCustomCell<Warrant> {

    static let identifier = String(describing: WarrantTableViewCell.self)

    private let customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.enableAutoLayout()
        imageView.backgroundColor = .appBackground
        imageView.width(80).height(80)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let situationLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoBold.withSize(12)
        label.enableAutoLayout()
        return label
    }()

    private let nameLB: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize(14)
        label.enableAutoLayout()
        label.textColor = .appCellLabel
        label.numberOfLines = 0
        return label
    }()

    private let typeLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoItalic.withSize(12)
        label.enableAutoLayout()
        label.textColor = .appLightGray
        label.numberOfLines = 0
        return label
    }()

    private let expeditionLB: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize(12)
        label.textColor = .appLightGray
        label.enableAutoLayout()
        return label
    }()

    private let dotView: UIView = {
        let view = UIView()
        view.enableAutoLayout()
        view.backgroundColor = .appRed
        view.height(10)
        view.layer.cornerRadius = 5
        return view
    }()

    private var dotWidth: NSLayoutConstraint!
    private var situationLeading: NSLayoutConstraint!

    var shouldUseDotView = false {
        didSet {
            dotView.isHidden = !shouldUseDotView
        }
    }

    override func configure(using model: Warrant) {
        customImageView.image = UIImage(named: "user")
        situationLb.text = model.situation.uppercased()
        nameLB.text = model.personName.uppercased()
        expeditionLB.text = "Expedido em: \(model.expeditionDate.split(separator: "-").reversed().joined(separator: "/"))"
        backgroundColor = .appBackground
        shouldUseDotView = model.type.id == 1
        typeLb.text = model.type.name
    }

    override func prepareForReuse() {
        NSLayoutConstraint.deactivate([dotWidth])
    }

    override func layoutSubviews() {
        addSubview(situationLb)
        addSubview(nameLB)
        addSubview(expeditionLB)
        addSubview(customImageView)
        addSubview(dotView)
        addSubview(typeLb)
        if let width = dotWidth {
            NSLayoutConstraint.deactivate([width, situationLeading])
        }
        dotWidth = dotView.widthAnchor.constraint(equalToConstant: 0)
        dotWidth.constant = shouldUseDotView ? 10 : 0
        if shouldUseDotView {
            situationLeading = situationLb.leadingAnchor.constraint(equalToSystemSpacingAfter: dotView.trailingAnchor, multiplier: 1)
        } else {
            situationLeading = situationLb.leadingAnchor.constraint(equalToSystemSpacingAfter: customImageView.trailingAnchor, multiplier: 1)
        }

        NSLayoutConstraint.activate([dotWidth, situationLeading])

        NSLayoutConstraint.activate([
            customImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            customImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            situationLb.topAnchor.constraint(equalTo: customImageView.topAnchor),

            typeLb.leadingAnchor.constraint(equalToSystemSpacingAfter: customImageView.trailingAnchor, multiplier: 1),
            typeLb.topAnchor.constraint(equalTo: situationLb.bottomAnchor),

            nameLB.leadingAnchor.constraint(equalTo: typeLb.leadingAnchor),
            nameLB.topAnchor.constraint(equalTo: typeLb.bottomAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: nameLB.trailingAnchor, multiplier: 1),

            expeditionLB.leadingAnchor.constraint(equalTo: nameLB.leadingAnchor),
            expeditionLB.bottomAnchor.constraint(equalTo: customImageView.bottomAnchor),

            dotView.topAnchor.constraint(equalTo: customImageView.topAnchor),
            dotView.leadingAnchor.constraint(equalToSystemSpacingAfter: customImageView.trailingAnchor, multiplier: 1)
        ])

    }
}
