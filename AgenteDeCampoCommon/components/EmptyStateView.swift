//
//  NotFoundView.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 25/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public protocol EmptyStateViewDelegate: class {
    func didClickActionButton(_ button: UIButton)
}

public class EmptyStateView: UIView {

    public weak var delegate: EmptyStateViewDelegate?

    public var onAction: (() -> Void)?

    let topView = UIView()
    let bottomView = UIView()
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.enableAutoLayout()
        return stack
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.robotoBold.withSize(16)
        label.textColor = .appTitle
        return label
    }()

    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.robotoMedium.withSize(14)
        label.textColor = .appLightGray
        return label
    }()

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.enableAutoLayout()
        return view
    }()

    public let actionButton: AGCRoundedButton = {
        let button = AGCRoundedButton(text: "Tentar novamente")
        return button
    }()

    private var hasSubtitle = false

    public init(title: String, subTitle: String?, image: UIImage = UIImage(named: "notFound")! ) {
        super.init(frame: .zero)
        titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.imageView.image = image
        hasSubtitle = subTitle != nil
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        stack.addArrangedSubview(topView)
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(titleLabel)
        if let text =  subTitleLabel.text, !text.isEmpty {
            stack.addArrangedSubview(subTitleLabel)
        }
        bottomView.addSubview(actionButton)
        bottomView.enableAutoLayout()
        stack.addArrangedSubview(bottomView)
        addSubview(stack)
        stack.fillSuperView(regardSafeArea: true)
        setupContraint()
        actionButton.addTarget(self, action: #selector(buttonDidClick), for: .touchUpInside)

        stack.setCustomSpacing(30, after: imageView)
        stack.setCustomSpacing(16, after: titleLabel)
        stack.setCustomSpacing(50, after: subTitleLabel)

        actionButton.isHidden = (self.delegate == nil) && (self.onAction == nil)
    }

    func setupContraint() {
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: stack.heightAnchor, multiplier: 0.3),
            topView.heightAnchor.constraint(equalToConstant: 50),
            actionButton.topAnchor.constraint(equalTo: bottomView.topAnchor),
            actionButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            actionButton.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.5),
            actionButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc
    func buttonDidClick() {
        delegate?.didClickActionButton(actionButton)
        self.onAction?()
    }
}
