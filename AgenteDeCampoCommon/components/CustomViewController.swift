//
//  CustomViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 29/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

open class CustomViewController: UIViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupConstraints()
    }

    open func addSubviews() {

    }

    open func setupConstraints() {

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let style = UserStylePreferences.theme.style
        view.overrideUserInterfaceStyle = style
    }
}
