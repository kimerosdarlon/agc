//
//  DriverAlertHeader.swift
//  Driver
//
//  Created by Samir Chaves on 26/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class DriverAlertHeader: UIStackView {

    init() {
        super.init(frame: .zero)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let sinceDateLabel = UILabel.build(withSize: 13, color: .white)
    private let descriptionLabel = UILabel.build(withSize: 14, weight: .bold, color: .white)

    private lazy var shieldImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "shield.lefthalf.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal) )
        view.enableAutoLayout().height(30).width(30)
        view.contentMode = .scaleAspectFit
        return view
    }()

    func configure(driver: Driver) {
        let currentCnh = driver.general.currentCnh

        if let timeToExpire = currentCnh.getTimeToExpire(),
           let expirationDate = currentCnh.getExpirationDate(),
           currentCnh.isOverdue() {
            self.backgroundColor = .appYellow
            sinceDateLabel.text = timeToExpire.humanize(shortText: false)
            descriptionLabel.text = "Vencida desde \(expirationDate.format(to: "dd/MM/yyyy"))"
        }

        if let timeHasSuspended = currentCnh.getTimeHasSuspended(),
           let suspendedUntil = currentCnh.getSuspensionEndDate(),
           currentCnh.isSuspended() {
            self.backgroundColor = .appRedAlert
            sinceDateLabel.text = timeHasSuspended.humanize(shortText: false)
            descriptionLabel.text = "Suspensa até \(suspendedUntil.format(to: "dd/MM/yyyy"))"
        }

        if currentCnh.hasAlerts() {
            self.addSubview(shieldImage)
            self.addSubview(sinceDateLabel)
            self.addSubview(descriptionLabel)
            height(50)

            NSLayoutConstraint.activate([
                sinceDateLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -1),
                sinceDateLabel.leadingAnchor.constraint(equalTo: shieldImage.trailingAnchor, constant: 15),
                descriptionLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 1),
                descriptionLabel.leadingAnchor.constraint(equalTo: sinceDateLabel.leadingAnchor),
                shieldImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
                shieldImage.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        } else {
            heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
}
