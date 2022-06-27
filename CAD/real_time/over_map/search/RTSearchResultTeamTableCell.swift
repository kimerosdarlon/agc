//
//  RTSearchResultTeamTableCell.swift
//  CAD
//
//  Created by Samir Chaves on 06/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class RTSearchResultTeamTableCell: UITableViewCell {
    static let identifier = String(describing: RTSearchResultTeamTableCell.self)

    private let icon: UIImageView = {
        let alarmIcon = UIImage(named: "people")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: alarmIcon)
        imageView.alpha = 0.7
        return imageView.enableAutoLayout()
    }()

    private let nameLabel = UILabel.build(withSize: 13, color: .appTitle)
    private let matchedTextLabel = UILabel.build(withSize: 13, color: .appTitle)
    private let centerView: UIStackView = {
        let stack = UIStackView().enableAutoLayout()
        stack.axis = .vertical
        stack.spacing = 7
        stack.alignment = .leading
        return stack
    }()

    override func didMoveToSuperview() {
        addSubview(centerView)
        centerView.addArrangedSubviewList(views: nameLabel, matchedTextLabel)
        matchedTextLabel.numberOfLines = 1
        addSubview(icon)
        backgroundColor = .clear
        selectionStyle = .none

        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 13),

            centerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerView.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 15),
            centerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    func configure(with result: RTSearchResult) {
        guard let team = result.team else { return }
        nameLabel.text = team.name

        let matchedText: NSMutableAttributedString = NSMutableAttributedString()
        let matchedTextField = NSAttributedString(string: "\(result.matchedField): ",
                                                  attributes: [.foregroundColor: UIColor.appBlue])
        let matchedTextValue = NSMutableAttributedString(
            string: "\(result.fieldValue)",
            attributes: [.foregroundColor: UIColor.appTitle.withAlphaComponent(0.6)]
        )
        matchedTextValue.setAttributes([
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.appTitle.withAlphaComponent(1)
        ], range: result.range)
        matchedText.append(matchedTextField)
        matchedText.append(matchedTextValue)
        matchedTextLabel.attributedText = matchedText
    }
}
