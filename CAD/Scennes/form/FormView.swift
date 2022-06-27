//
//  FormViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 11/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class FormView: UIView {

    private var fields: [UIView]

    private var stackView: UIStackView = {
        let stack = UIStackView().enableAutoLayout()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()

    init(fields: [UIView], horizontal: Bool = false) {
        self.fields = fields
        super.init(frame: .zero)
        if horizontal {
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.alignment = .leading
        }
        addSubviews()
    }

    private func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubviewList(views: fields)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        if stackView.axis == .horizontal {
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
