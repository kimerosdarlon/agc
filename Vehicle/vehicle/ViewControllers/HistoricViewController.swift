//
//  HistoricViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 10/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class HistoricViewController: UIViewController {

    init(title: String, subTitle: String, text: String?) {
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        detailLabel.text = subTitle
        self.descriptionTextView.text = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.textColor = .appTitle
        label.font = UIFont.robotoMedium.withSize(18)
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.textColor = .appLightGray
        label.font = UIFont.robotoRegular.withSize(12)
        return label
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.allowsEditingTextAttributes = false
        textView.dataDetectorTypes = [.address, .phoneNumber, .calendarEvent]
        textView.enableAutoLayout()
        textView.backgroundColor = .appBackground
        textView.textColor = .appCellLabel
        textView.font = UIFont.robotoRegular.withSize(14)
        return textView
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.enableAutoLayout()
        button.setTitleColor(.red, for: .normal)
        button.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(descriptionTextView)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didClickOnCloseButton), for: .touchUpInside)

        titleLabel.centerX().top(mutiplier: 3)
        detailLabel.top(to: titleLabel.bottomAnchor, mutiplier: 3).left(mutiplier: 2.5)
        descriptionTextView.top(to: detailLabel.bottomAnchor, mutiplier: 1.5).left(mutiplier: 2)
        closeButton.centerY(view: titleLabel)
        view.bottom(to: descriptionTextView.bottomAnchor, 2)
            .right(to: descriptionTextView.trailingAnchor, 2)
            .right(to: closeButton.trailingAnchor, 2)
    }

    @objc
    private func didClickOnCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
