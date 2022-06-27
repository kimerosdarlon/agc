//
//  MemberModalViewController.swift
//  CAD
//
//  Created by Samir Chaves on 02/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class MemberModalViewController: UIViewController {

    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    private var member: MemberViewModel
    private var listBuilder: ListBasedDetailBuilder?
    private static let memberImageSize: CGFloat = 110
    private let nameLabel = UILabel.build(withSize: 16, color: .appTitle)
    private let roleLabel = UILabel.build(withSize: 14, alpha: 0.6, color: .appTitle)
    private let closeButton: AGCRoundedButton = {
        let button = AGCRoundedButton(text: "Fechar", loadingText: "")
        button.backgroundColor = .appLightGray
        button.layer.cornerRadius = 15
        button.setTitleColor(.white, for: .disabled)
        button.addTarget(self, action: #selector(closeModal), for: UIControl.Event.touchUpInside)
        button.enableAutoLayout()
        return button
    }()

    private var memberImageView: UIImageView = {
        let imageView = UIImageView().height(memberImageSize).width(memberImageSize).enableAutoLayout()
        imageView.backgroundColor = .imageBackGround
        imageView.layer.cornerRadius = memberImageSize/2
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var scrollContainer: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.enableAutoLayout()
        return scroll
    }()

    init(person: TeamPerson) {
        member = MemberViewModel(member: person)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .appBackground
        modalPresentationStyle = .custom
        memberImageView.image = member.image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func closeModal() {
        self.dismiss(animated: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        transitionDelegate = PresentationManager(padding: .init(top: 0, left: 0, bottom: -60, right: 0), heightFactor: 0.4)
        transitioningDelegate = transitionDelegate
        configure()
        addSubviews()
        setupLayout()
    }

    private func configure() {
        nameLabel.text = member.fullname
        roleLabel.text = member.role

        listBuilder = ListBasedDetailBuilder(into: scrollContainer, padding: .init(top: 5, left: 5, bottom: 5, right: 5))
    }

    private func setupLayout() {
        scrollContainer.width(view)
        closeButton.height(50)
        NSLayoutConstraint.activate([
            memberImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            memberImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -MemberModalViewController.memberImageSize / 1.5),

            nameLabel.topAnchor.constraint(equalTo: memberImageView.bottomAnchor, constant: 15),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            roleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollContainer.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollContainer.bottomAnchor, multiplier: 1),

            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 10),

            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
        listBuilder?.setupLayout()
    }

    private func fillBlankField(_ value: String?) -> String {
        value == nil ? "————" : value!.fillEmpty()
    }

    private func addSubviews() {
        view.addSubview(memberImageView)
        view.addSubview(nameLabel)
        view.addSubview(roleLabel)
        view.addSubview(closeButton)
        view.addSubview(scrollContainer)

        let detailsGroup = DetailsGroup(items: [
            [InteractableDetailItem(fromItem: (title: "Agência:", detail: "\(member.agency.name) - \(member.agency.initials)"), hasInteraction: false)],
            [
                InteractableDetailItem(fromItem: (title: "Cargo:", detail: fillBlankField(member.responsibility)), hasInteraction: false),
                InteractableDetailItem(fromItem: (title: "Matrícula:", detail: fillBlankField(member.registration)), hasInteraction: false)
            ],
            [
                InteractableDetailItem(fromItem: (title: "Nome Funcional:", detail: fillBlankField(member.name)), hasInteraction: false),
                InteractableDetailItem(fromItem: (title: "Celular:", detail: fillBlankField(member.cellphone)), hasInteraction: member.cellphone != nil)
            ],
            [
                InteractableDetailItem(fromItem: (title: "Telefone fixo:", detail: fillBlankField(member.telephone)), hasInteraction: member.telephone != nil)
            ]
        ])

        listBuilder?.buildDetailsBlock(
            DetailsBlock(group: detailsGroup, identifier: "details")
        )
    }
}
