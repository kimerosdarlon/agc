//
//  OperationalBreakViewController.swift
//  CAD
//
//  Created by Samir Chaves on 15/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class OperationalBreakViewController: UIViewController {
    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    private let doneBtn: UIButton = {
        let btn = AGCRoundedButton(text: "Ciente", loadingText: "").enableAutoLayout()
        btn.addTarget(self, action: #selector(didTapInDoneBtn), for: .touchUpInside)
        return btn
    }()

    private let titleLabel = UILabel.build(withSize: 18, weight: .bold, color: .appTitle, text: "Pausa Operacional")
    private let subtitleLabel = UILabel.build(
        withSize: 16,
        alpha: 0.7,
        color: .appTitle,
        text: "Sua equipe entrou em pausa operacional, verifique se as informações abaixo"
    )
    private let detailsHeader = UIView(frame: .zero).enableAutoLayout()
    private let headerIcon: UIImageView = {
        let image = UIImage(systemName: "calendar")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let imageView = UIImageView().enableAutoLayout()
        imageView.image = image
        return imageView.width(25).height(25)
    }()
    private let detailsTitleLabel = UILabel.build(withSize: 16, weight: .bold, color: .appTitle)
    private var listBuilder: ListBasedDetailBuilder!
    private let detailsView = UIScrollView(frame: .zero).enableAutoLayout()

    private let operationalBreak: OperationalBreakPushNotification

    @CadServiceInject
    private var cadService: CadService

    init(data: OperationalBreakPushNotification) {
        self.operationalBreak = data
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom

        transitionDelegate = DefaultModalPresentationManager()
        transitioningDelegate = transitionDelegate

        listBuilder = ListBasedDetailBuilder(into: detailsView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapInDoneBtn() {
        dismiss(animated: true)
    }

    private func getEquipmentsDetails() -> [[InteractableDetailItem]] {
        let equipmentChunks = operationalBreak.equipments.chunked(into: 2)
        let equipmentDetailsViews = equipmentChunks.map { equipments -> UIView in
            let view = UIStackView(frame: .zero)
            view.alignment = .fill
            view.axis = .horizontal
            view.distribution = .fillEqually
            let details = equipments.map { equipment -> UIView in
                let label = UILabel()
                let description = "\(equipment.prefix) \(equipment.kmSupply.map { "\($0)km" } ?? "")"
                let text = NSMutableAttributedString(string: "PREFIXO ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
                text.append(NSAttributedString(string: description, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
                label.attributedText = text
                return label
            }
            view.addArrangedSubviewList(views: details)
            return view
        }
        let equipmentDetailsView = UIStackView().enableAutoLayout()
        equipmentDetailsView.axis = .vertical
        equipmentDetailsView.alignment = .fill
        equipmentDetailsView.spacing = 10
        equipmentDetailsView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 10)
        equipmentDetailsView.addArrangedSubviewList(views: equipmentDetailsViews)

        let equipmentDetails = InteractableDetailItem(fromItem: (title: "Equipamentos", view: equipmentDetailsView))
        return [[equipmentDetails]]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(detailsHeader)
        detailsHeader.addSubview(detailsTitleLabel)
        detailsHeader.addSubview(headerIcon)
        view.addSubview(detailsView)
        view.addSubview(doneBtn)

        let textualDetails: [[InteractableDetailItem]] = [
            InteractableDetailItem.noInteraction(
                [(title: "Descrição", detail: operationalBreak.operationalBreakTypeDescription ?? String.emptyProperty)]
            ),
            InteractableDetailItem.noInteraction(
                [(title: "Observações", detail: operationalBreak.observations ?? String.emptyProperty)]
            )
        ]
        let equipmentDetails = getEquipmentsDetails()
        let detailsGroup = DetailsGroup(items: textualDetails + equipmentDetails)
        listBuilder.buildDetailsBlock(DetailsBlock(group: detailsGroup, identifier: "equipment"))
        listBuilder.setupLayout()

        let formattedDateTime = operationalBreak.dateTime.toDate(format: "yyyy-MM-dd'T'HH:mm:ss")?.format(to: "dd/MM/yyyy 'às' HH:mm")
        detailsTitleLabel.text = formattedDateTime
        setupLayout()
    }

    private func setupLayout() {
        let padding: CGFloat = 20
        let safeArea = view.safeAreaLayoutGuide
        detailsHeader.height(40)
        detailsHeader.backgroundColor = .appBackgroundCell
        doneBtn.width(view.widthAnchor, multiplier: 0.6).height(40)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            detailsHeader.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 15),
            detailsHeader.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            detailsHeader.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),

            headerIcon.centerYAnchor.constraint(equalTo: detailsHeader.centerYAnchor),
            headerIcon.leadingAnchor.constraint(equalTo: detailsHeader.leadingAnchor, constant: 10),

            detailsTitleLabel.centerYAnchor.constraint(equalTo: detailsHeader.centerYAnchor),
            detailsTitleLabel.leadingAnchor.constraint(equalTo: headerIcon.trailingAnchor, constant: 10),
            detailsTitleLabel.trailingAnchor.constraint(equalTo: detailsHeader.trailingAnchor, constant: -10),

            detailsView.topAnchor.constraint(equalTo: detailsTitleLabel.bottomAnchor),
            detailsView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: doneBtn.topAnchor, constant: -padding),

            doneBtn.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            doneBtn.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -padding)
        ])
    }
}
