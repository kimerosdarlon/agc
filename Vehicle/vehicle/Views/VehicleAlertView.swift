//
//  AlertHeaderView.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 01/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

protocol VehicleAlertViewDelegate: class {
    func expandButtonDidClickWith(state expanded: Bool)
    func showHistoric()
}

class VehicleAlertView: UIView {

    weak var delegate: VehicleAlertViewDelegate?

    private(set) var expanded = false

    private lazy var shieldImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "shield.lefthalf.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal) )
        view.enableAutoLayout().height(30).width(30)
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let historicButton: UIButton = {
        let button = UIButton()
        button.setTitle("Histórico", for: .normal)
        button.setImage(UIImage(systemName: "eye.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.robotoMedium.withSize(16)
        return button
    }()

    private let button: UIButton = {
        let btn = UIButton()
        btn.enableAutoLayout()
        btn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        btn.enableAutoLayout().height(22).width(22)
        btn.tintColor = .white
        return btn
    }()

    let builder: GenericDetailBuilder = {
        let builder = GenericDetailBuilder()
        builder.configurations.regularLabelColor = .white
        builder.configurations.boldLabelColor = UIColor.white.withAlphaComponent(0.6)
        builder.configurations.boldFontSize = 12
        builder.configurations.regularFontSize = 16
        builder.configurations.verticalSpacing = 1
        builder.configurations.detailLabelBackgroundColor = .appRedAlert
        return builder
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.addTarget(self, action: #selector(didTapOnView), for: .touchUpInside)
        historicButton.addTarget(self, action: #selector(didClickOnHistoricButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc
    private func didClickOnHistoricButton() {
        delegate?.showHistoric()
    }

    @objc
    private func didTapOnView() {
        delegate?.expandButtonDidClickWith(state: expanded)
        expanded.toggle()
        let angle: CGFloat =  -0.999999 * CGFloat.pi
        if expanded {
            UIView.animate(withDuration: 0.4) {
                self.button.transform = CGAffineTransform(rotationAngle: angle)
            }
        } else {
            UIView.animate(withDuration: 0.4) {
                self.button.transform = CGAffineTransform.identity
            }
        }
    }

    private func getVerticalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }

    private func buildDefaultAlert(_ alert: VehicleAlert) {
        backgroundColor = .appRedAlert
        let model = VehicleAlertViewModel(alert: alert)
        let stack = getVerticalStack()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        stack.addArrangedSubviewList(
            views: builder.horizontalStack( spacing: 8, alignment: .center ).addArrangedSubviewList(
                views: shieldImage,
                builder.verticalStack().addArrangedSubviewList(
                    views: builder.labelRegular(with: model.headerDate, size: 12),
                    builder.labelBold(with: model.headerTitle, color: .white),
                    builder.labelRegular(with: model.headerSource, size: 12)
                ),
                button
            ).addGesture(tap),
            builder.horizontalDivider(lineWidth: 1, color: .white),
            builder.titleDetail(title: "Unidade Policial", detail: model.pocileStation),
            builder.line(
                views: builder.titleDetail(title: "Protocolo", detail: model.bulleetimProtocol, hasInteraction: model.bulleetimProtocol.count > 3),
                builder.titleDetail(title: "Cidade/UF", detail: model.city),
                distribuition: .fillEqually
            ),
            builder.line(
                views: builder.titleDetail(title: "Nome", detail: model.name, hasInteraction: model.name.count > 3),
                builder.titleDetail(title: "Data", detail: model.date),
                distribuition: .fillEqually
            ),
            builder.line(
                views: builder.titleDetail(title: "Contato", detail: model.phone, hasInteraction: model.phone.count > 3),
                builder.titleDetail(title: "Ramal", detail: model.ramal),
                distribuition: .fillEqually
            ),
            builder.horizontalDivider(lineWidth: 1, color: .white),
            historicButton
        )

        addSubview(stack)
        stack.enableAutoLayout()
        stack.left(mutiplier: 2).top(mutiplier: 1)
        right(to: stack.trailingAnchor, 2)
    }

    private func buildEmptyAlert() {
        backgroundColor = .appRedAlert
        let stack = getVerticalStack()
        stack.spacing = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        stack.addArrangedSubviewList(
            views: builder.horizontalStack( spacing: 8, alignment: .center ).addArrangedSubviewList(
                views: shieldImage,
                builder.verticalStack(spacing: 4).addArrangedSubviewList(
                    views: builder.labelBold(with: "Veículo roubado/furtado", color: .white, size: 14),
                    builder.labelRegular(with: "FONTE: DENATRAN", size: 14)
                ),
                button
            ).height(60).addGesture(tap),
            builder.horizontalDivider(lineWidth: 1, color: .white),
            UILabel.build(withSize: 14, color: .white, alignment: .center, text: "Os detalhes da restrição não estão disponíveis no momento.")
                .height(70)
        )

        addSubview(stack)
        stack.enableAutoLayout()
        stack.left(mutiplier: 2).top(mutiplier: 0).height(130)
        right(to: stack.trailingAnchor, 2)
    }

    private func buildUnknownAlert() {
        backgroundColor = .appWarning
        let stack = getVerticalStack()
        stack.addArrangedSubviewList(
            views: builder.horizontalStack(spacing: 8, alignment: .center).addArrangedSubviewList(
                views: shieldImage,
                UILabel.build(withSize: 15, color: .white, text: "Não foi possível recuperar as restrições do veículo.")
            )
        )

        addSubview(stack)
        stack.enableAutoLayout()
        stack.left(mutiplier: 2).top(mutiplier: 0).bottom(to: bottomAnchor, 0)
        right(to: stack.trailingAnchor, 2)
    }

    func configure(with alert: VehicleAlert?, hasAlert: Bool, alertSystemOutOfService: Bool) {
        if hasAlert {
            if let alert = alert {
                buildDefaultAlert(alert)
            } else {
                buildEmptyAlert()
            }
        } else if alertSystemOutOfService {
            buildUnknownAlert()
        }
        layer.masksToBounds = true
    }
}
