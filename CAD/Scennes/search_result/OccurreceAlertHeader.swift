//
//  OccurreceAlertHeader.swift
//  CAD
//
//  Created by Samir Chaves on 09/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class OccurrenceAlertHeader: UIStackView {
    private let dateTime: Date?

    init(dateTime: Date?) {
        self.dateTime = dateTime
        super.init(frame: .zero)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleLabel = UILabel.build(withSize: 14, weight: .bold, color: .white)
    private let dateLabel = UILabel.build(withSize: 12.5, color: UIColor.white.withAlphaComponent(0.8))
    private let descriptionLabel = UILabel.build(withSize: 13, color: UIColor.white.withAlphaComponent(0.8))

    private lazy var iconImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal) )
        view.enableAutoLayout().height(25).width(25)
        view.contentMode = .scaleAspectFit
        return view
    }()

    func configure() {
        self.addSubview(iconImage)
        self.addSubview(titleLabel)
        self.addSubview(dateLabel)
        self.addSubview(descriptionLabel)
        enableAutoLayout().height(68)
        backgroundColor = .appRedAlert

        titleLabel.text = "Alerta geral!"
        dateLabel.text = dateTime?.difference(to: Date(), [.year, .month, .day]).humanize(shortText: false) ?? ""
        descriptionLabel.text = "Esta ocorrência recebeu um alerta geral"

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 15),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3),
            descriptionLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            iconImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            iconImage.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
