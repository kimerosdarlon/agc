//
//  OccurrenceMultilinePropertyView.swift
//  CAD
//
//  Created by Samir Chaves on 09/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

typealias OccurrenceProperty = (title: String, description: String)

class OccurrenceMultilineTextPropertyView: OccurrencePropertyView {
    init(_ properties: [OccurrenceProperty], iconName: String, iconColor: UIColor? = nil, extra: UIView? = nil) {
        let stack = UIStackView().enableAutoLayout()
        stack.spacing = 8
        stack.axis = .vertical
        for property in properties {
            let titleLabel = UILabel.build(withSize: 13, weight: .bold, color: .appTitle, text: property.title)
            let descriptionLabel = UILabel.build(withSize: 13, weight: .none, color: UIColor.appTitle.withAlphaComponent(0.7))
            let attributedString = NSMutableAttributedString(string: property.description)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
            descriptionLabel.attributedText = attributedString
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(descriptionLabel)
            stack.setCustomSpacing(13, after: descriptionLabel)
        }
        super.init(
            title: "",
            descriptionView: stack,
            iconName: iconName,
            iconColor: iconColor,
            extra: extra
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
