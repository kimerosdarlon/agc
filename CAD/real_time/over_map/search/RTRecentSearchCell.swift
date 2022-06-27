//
//  RTRecentSearchCell.swift
//  CAD
//
//  Created by Samir Chaves on 12/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class RTRecentSearchCell: UITableViewCell {
    static let identifier = String(describing: RTRecentSearchCell.self)

    private let icon: UIImageView = {
        let alarmIcon = UIImage(systemName: "clock.arrow.circlepath")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: alarmIcon)
        imageView.alpha = 0.7
        return imageView.enableAutoLayout()
    }()

    private let queryLabel = UILabel.build(withSize: 13, color: .appTitle)

    override func didMoveToSuperview() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(icon)
        addSubview(queryLabel)
        queryLabel.numberOfLines = 1

        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 18),

            queryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            queryLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 15),
            queryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    func configure(with query: String) {
        queryLabel.text = query
    }
}
