//
//  HeaderViewInterector.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class HeaderInteractorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        enableAutoLayout()
        let bar = UIView()
        bar.backgroundColor = .appTitle
        bar.enableAutoLayout()
        addSubview(bar)
        bar.centerX().width(40).height(3)
        bottom(to: bar.bottomAnchor, 1)
        bar.layer.cornerRadius = 5
        backgroundColor = .appBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
