//
//  OccurrenceTextPropertyView.swift
//  CAD
//
//  Created by Samir Chaves on 16/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class OccurrenceTextPropertyView: OccurrencePropertyView {
    init(title: String, description: String?, iconName: String, iconColor: UIColor? = nil, extra: UIView? = nil, editable: Bool = false) {
        super.init(
            title: title,
            descriptionView: UILabel.build(withSize: 14, alpha: 0.7, text: description),
            iconName: iconName,
            iconColor: iconColor,
            extra: extra,
            editable: editable
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
