//
//  EquipmentGroupModalswift.swift
//  CAD
//
//  Created by Samir Chaves on 09/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class EquipmentModalViewController: UIViewController {

    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    private var equipmentGroup: EquipmentGroup
    private var equipmentPager: SwipingViewController
    private static let equipmentImageSize: CGFloat = 110
    private let nameLabel = UILabel.build(withSize: 16, color: .appTitle)
    private let containerView = UIView(frame: .zero).enableAutoLayout()
    private let closeButton: AGCRoundedButton = {
        let button = AGCRoundedButton(text: "Fechar", loadingText: "")
        button.backgroundColor = .appLightGray
        button.layer.cornerRadius = 15
        button.setTitleColor(.white, for: .disabled)
        button.addTarget(self, action: #selector(closeModal), for: UIControl.Event.touchUpInside)
        button.enableAutoLayout()
        return button
    }()

    private var equipmentImageContainer: UIView = {
        let container = UIView().enableAutoLayout().height(equipmentImageSize).width(equipmentImageSize)
        container.backgroundColor = .appBackgroundCell
        container.layer.cornerRadius = equipmentImageSize / 2
        return container
    }()

    private var equipmentImageView: UIImageView = {
        let imageView = UIImageView().enableAutoLayout().height(equipmentImageSize / 2).width(equipmentImageSize / 2)
//        imageView.backgroundColor = .imageBackGround
//        imageView.layer.cornerRadius = equipmentImageSize / 4
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()

    init(group: EquipmentGroup) {
        equipmentGroup = group
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        equipmentPager = SwipingViewController(equipments: group.equipments, layout: layout)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        containerView.backgroundColor = .appBackground
        containerView.layer.cornerRadius = 15
        modalPresentationStyle = .custom
        equipmentImageView.image = equipmentGroup.image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func closeModal() {
        self.dismiss(animated: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        transitionDelegate = PresentationManager(padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        transitioningDelegate = transitionDelegate
        configure()
        addSubviews()
        setupLayout()
    }

    private func configure() {
        nameLabel.text = "\(equipmentGroup.name) (\(equipmentGroup.equipments.count))"
    }

    private func setupLayout() {
        closeButton.height(50)
        NSLayoutConstraint.activate([
            equipmentImageContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            equipmentImageContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: -EquipmentModalViewController.equipmentImageSize / 1.5),

            nameLabel.topAnchor.constraint(equalTo: equipmentImageContainer.bottomAnchor, constant: 15),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),

            equipmentPager.view.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            equipmentPager.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            equipmentPager.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            equipmentPager.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10)
        ])
    }

    private func addSubviews() {
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(equipmentPager.view)
        view.addSubview(equipmentImageContainer)
        equipmentImageContainer.addSubview(equipmentImageView)
        equipmentImageView.centerX(view: equipmentImageContainer)
        equipmentImageView.centerY(view: equipmentImageContainer)
        equipmentPager.view.enableAutoLayout()
        addChild(equipmentPager)
        equipmentPager.didMove(toParent: self)
        view.addSubview(closeButton)
    }
}
