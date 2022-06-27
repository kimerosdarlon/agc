//
//  InsertAttatchmentsFeedbackView.swift
//  CAD
//
//  Created by Samir Chaves on 27/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class InsertAttachmentsFeedbackView: UIView {
    private let titleLabel = UILabel.build(withSize: 13, weight: .bold, color: .appTitle, text: "Anexos")
    private let messageLabel = UILabel.build(withSize: 13, alpha: 0.6, color: .appTitle, text: "Os anexos somente poderão ser gerenciados após o cadastro da entidade.")

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(titleLabel)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10)
        ])
    }
}
