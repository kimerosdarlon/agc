//
//  OccurrencePriorityLabel.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class OccurrencePriorityLabel: UIView {

    private var widthContraint: NSLayoutConstraint?
    private var heightContraint: NSLayoutConstraint?

    var priorityColor = UIColor.appRed
    private var priorityIcon: UIImageView = {
        let view = UIImageView(image: nil)
        view.enableAutoLayout().height(13).width(13)
        view.contentMode = .scaleAspectFill
        return view
    }()

    private var priorityLabel: UILabel = UILabel.build(withSize: 12)

    func withPriority(_ priority: OccurrencePriority, maxWidth: CGFloat = 1000) -> OccurrencePriorityLabel {
        var priorityIconName = "chevron.up"
        priorityColor = priority.color

        switch priority {
        case .low:
            priorityIconName = "chevron.down"
        case .medium:
            priorityIconName = "minus"
        case .redAlert:
            priorityIconName = "chevron.up"
        default:
            priorityIconName = "chevron.up"
        }

        widthContraint?.isActive = false
        heightContraint?.isActive = false

        let estimatedWidth = priority.rawValue.width(withConstrainedHeight: 15, font: priorityLabel.font) + 19
        if estimatedWidth > maxWidth {
            widthContraint = self.widthAnchor.constraint(equalToConstant: maxWidth)
        } else {
            heightContraint = self.heightAnchor.constraint(equalToConstant: 15)
            heightContraint?.isActive = true
            widthContraint = self.widthAnchor.constraint(equalToConstant: estimatedWidth)
        }
        widthContraint?.isActive = true
        priorityIcon.image = UIImage(systemName: priorityIconName)?.withTintColor(priorityColor, renderingMode: .alwaysOriginal)
        priorityLabel.textColor = priorityColor
        priorityLabel.text = priority.rawValue

        return self
    }

    override func didMoveToSuperview() {
        enableAutoLayout()
        addSubview(priorityIcon)
        addSubview(priorityLabel)

        NSLayoutConstraint.activate([
            priorityIcon.centerYAnchor.constraint(equalTo: priorityLabel.centerYAnchor),
            priorityIcon.leadingAnchor.constraint(equalTo: leadingAnchor),

            topAnchor.constraint(equalTo: priorityLabel.topAnchor),
            priorityLabel.leadingAnchor.constraint(equalTo: priorityIcon.trailingAnchor, constant: 5),
            bottomAnchor.constraint(equalTo: priorityLabel.bottomAnchor),

            priorityLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
