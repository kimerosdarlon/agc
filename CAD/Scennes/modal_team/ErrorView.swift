//
//  ErrorView.swift
//  CAD
//
//  Created by Samir Chaves on 15/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class ErrorView: UIView {
    let message = UILabel.build(withSize: 14, color: .appTitle)
    let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)).enableAutoLayout()

    func setText(_ text: String) {
        message.text = text
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = .appRedAlert
        layer.cornerRadius = 5

        addSubview(message)
        addSubview(icon)

        let padding: CGFloat = 12
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: message.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            message.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            message.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            message.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: padding),
            message.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
}
