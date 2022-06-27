//
//  OccurrenceUpdatesView.swift
//  CAD
//
//  Created by Samir Chaves on 17/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class OccurrenceUpdatesView: UIStackView {

    private let breadCrumbLabel = UILabel.build(withSize: 14, alpha: 0.7, color: .appTitle)
    private let keyLabel = UILabel.build(withSize: 15, weight: .bold, color: .appTitle)
    private let keyValue = UILabel.build(withSize: 15, alpha: 0.6, color: .appTitle)
    private let item: OccurrenceUpdateItem

    init(item: OccurrenceUpdateItem) {
        self.item = item
        super.init(frame: .zero)

        axis = .vertical
        alignment = .leading
        distribution = .fillProportionally
        spacing = 6
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        let itemPath = item.key.components(separatedBy: "::")
        if itemPath.count > 1 {
            breadCrumbLabel.text = itemPath[0..<itemPath.count-1].joined(separator: " | ") + " | "
            addArrangedSubview(breadCrumbLabel)
        }

        addArrangedSubview(keyLabel)
        addArrangedSubview(keyValue)
        keyLabel.text = itemPath[itemPath.count-1] + ":"
        keyValue.text = item.value
    }
}
