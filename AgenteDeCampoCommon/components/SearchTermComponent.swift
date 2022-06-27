//
//  SearchTermComponent.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 08/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class SearchTermComponent: UIView {

    let label = UILabel()

    init(text: String?) {
        super.init(frame: .zero)
        label.text = text
    }

    override func layoutSubviews() {
        addSubview(label)
        label.font = UIFont.robotoMedium.withSize(12)
        label.textColor = .label
        label.textAlignment = .center
        label.enableAutoLayout()
        label.fillSuperView(regardSafeArea: false)
        backgroundColor = .appBlue
        layer.masksToBounds = true
        label.textColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
