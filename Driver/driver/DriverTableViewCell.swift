//
//  DriverTableCellView.swift
//  Driver
//
//  Created by Samir Chaves on 28/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class DriverTableViewCell: MyCustomCell<Driver> {

    private let dateFormatter = DateFormatter()
    static let identifier = String(describing: DriverTableViewCell.self)

    private let customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.enableAutoLayout()
        imageView.backgroundColor = .appBackground
        imageView.width(80).height(80)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let statusLb = DriverStatusBadge(withInsets: 2.0, 2.0, 5.0, 5.0)

    private let nameLB: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize(14)
        label.enableAutoLayout()
        label.textColor = .appCellLabel
        label.numberOfLines = 0
        return label
    }()

    private let cnhLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoItalic.withSize(13)
        label.enableAutoLayout()
        label.textColor = .appCellLabel
        label.alpha = 0.6
        label.numberOfLines = 0
        return label
    }()

    private let expirationLB: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize(13)
        label.textColor = .appCellLabel
        label.alpha = 0.6
        label.enableAutoLayout()
        return label
    }()

    private var dotWidth: NSLayoutConstraint!
    private var situationLeading: NSLayoutConstraint!

    override func configure(using model: Driver) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "dd/MM/yyyy"

        let expirationDate = formatter.date(from: model.general.currentCnh.expirationDate)

        customImageView.image = UIImage(named: "roundedUser")
        statusLb.setStatus(model.general.currentCnh.status, withFontSize: 12)
        nameLB.text = model.individual.name
        expirationLB.text = expirationDate == nil ? "" : "Valido até: \(dateFormatter.string(from: expirationDate!))"
        backgroundColor = .appBackground
        let cnhLabelText = NSMutableAttributedString()
        cnhLabelText.append(NSAttributedString(string: "CNH: \(model.general.currentCnh.number) - ", attributes: nil))
        cnhLabelText.append(NSAttributedString(string: model.general.currentCnh.category.current, attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)
        ]))
        cnhLb.attributedText = cnhLabelText
    }

    override func layoutSubviews() {
        addSubview(statusLb)
        addSubview(nameLB)
        addSubview(expirationLB)
        addSubview(customImageView)
        addSubview(cnhLb)

        NSLayoutConstraint.activate([
            customImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            customImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            statusLb.leadingAnchor.constraint(equalToSystemSpacingAfter: customImageView.trailingAnchor, multiplier: 1),
            statusLb.topAnchor.constraint(equalTo: customImageView.topAnchor),

            nameLB.leadingAnchor.constraint(equalToSystemSpacingAfter: customImageView.trailingAnchor, multiplier: 1),
            nameLB.topAnchor.constraint(equalTo: statusLb.bottomAnchor, constant: 5),

            cnhLb.leadingAnchor.constraint(equalToSystemSpacingAfter: customImageView.trailingAnchor, multiplier: 1),
            cnhLb.topAnchor.constraint(equalTo: nameLB.bottomAnchor, constant: 5),

            trailingAnchor.constraint(equalToSystemSpacingAfter: nameLB.trailingAnchor, multiplier: 1),

            expirationLB.leadingAnchor.constraint(equalTo: cnhLb.leadingAnchor),
            expirationLB.bottomAnchor.constraint(equalTo: customImageView.bottomAnchor)
        ])

    }
}
