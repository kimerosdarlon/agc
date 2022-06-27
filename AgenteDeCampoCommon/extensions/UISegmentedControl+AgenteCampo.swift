//
//  UISegmentedControl+AgenteCampo.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 26/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public extension UISegmentedControl {

    func configureAppDefault() {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appCellLabel]
        setTitleTextAttributes(titleTextAttributes, for: .normal)
        let titleTextAttributesForSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        setTitleTextAttributes(titleTextAttributesForSelected, for: .selected)
        selectedSegmentTintColor = .appBlue
        backgroundColor = .appBackground
        tintColor = .white
        selectedSegmentIndex = 0
    }
}
