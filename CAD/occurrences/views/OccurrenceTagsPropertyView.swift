//
//  OccurrenceTagsPropertyView.swift
//  CAD
//
//  Created by Samir Chaves on 16/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class OccurrenceTagsPropertyView: OccurrencePropertyView {
    init(title: String, tags: [String], iconName: String, iconColor: UIColor? = nil, extra: UIView? = nil, editable: Bool = false) {
        super.init(
            title: title,
            descriptionView: TagGroupView(tags: tags, containerBackground: .appBackground).enableAutoLayout().height(40),
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
