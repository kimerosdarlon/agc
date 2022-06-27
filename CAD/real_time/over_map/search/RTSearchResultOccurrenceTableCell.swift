//
//  RTSearchResultTableCell.swift
//  CAD
//
//  Created by Samir Chaves on 06/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class RTSearchResultOccurrenceTableCell: UITableViewCell {
    static let identifier = String(describing: RTSearchResultOccurrenceTableCell.self)

    private let icon: UIImageView = {
        let alarmIcon = UIImage(named: "alarm")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: alarmIcon)
        imageView.alpha = 0.7
        return imageView.enableAutoLayout()
    }()
    private let addressLabel = UILabel.build(withSize: 13, color: .appTitle)
    private let matchedTextLabel = UILabel.build(withSize: 13, color: .appTitle)
    private let centerView: UIStackView = {
        let stack = UIStackView().enableAutoLayout()
        stack.axis = .vertical
        stack.spacing = 7
        stack.alignment = .leading
        return stack
    }()
    private let timeLabel = UILabel.build(withSize: 13, color: .appTitle)
    private var priority = OccurrencePriorityLabel().enableAutoLayout()
    private let asideView: UIStackView = {
        let stack = UIStackView().enableAutoLayout()
        stack.axis = .vertical
        stack.spacing = 7
        stack.alignment = .center
        return stack
    }()

    override func didMoveToSuperview() {
        addSubview(centerView)
        centerView.addArrangedSubviewList(views: addressLabel, matchedTextLabel)
        matchedTextLabel.numberOfLines = 1
        addSubview(asideView)
        asideView.addArrangedSubviewList(views: priority, timeLabel)
        addSubview(icon)
        backgroundColor = .clear
        selectionStyle = .none

        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 18),

            centerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerView.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 15),
            centerView.trailingAnchor.constraint(equalTo: asideView.leadingAnchor, constant: -10),

            asideView.centerYAnchor.constraint(equalTo: centerView.centerYAnchor),
            asideView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            asideView.widthAnchor.constraint(equalToConstant: 75)
        ])
    }

    func configure(with result: RTSearchResult) {
        guard let occurrence = result.occurrence else { return }
        let address = occurrence.address
        addressLabel.text = address.getFormattedAddress()

        priority = priority.withPriority(occurrence.priority, maxWidth: 75)

        let serviceRegisterDatetime = occurrence.serviceRegisteredAt.toDate(format: "yyyy-MM-dd'T'HH:mm:ss")
        timeLabel.text = serviceRegisterDatetime?
            .difference(to: Date(), [.year, .month, .day, .hour, .minute])
            .humanize(shortText: false, rounded: true)
        
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
