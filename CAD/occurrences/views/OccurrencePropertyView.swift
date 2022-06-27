//
//  OccurrencePropertyView.swift
//  CAD
//
//  Created by Samir Chaves on 14/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class OccurrencePropertyView: UIView {
    private let iconImage: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.enableAutoLayout().width(16).height(16)
        return imageView
    }()

    private let editIcon: UIButton = {
        let size: CGFloat = 42
        let image = UIImage(named: "pencil")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        btn.backgroundColor = .clear
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(didTapOnEditButton), for: .touchUpInside)
        return btn.enableAutoLayout().width(size).height(size)
    }()

    internal let titleLabel = UILabel.build(withSize: 12, weight: .bold)
    private var descriptionView: UIView?
    private var extraView: UIView!
    private let editable: Bool

    init(title: String,
         descriptionView: UIView?,
         iconName: String,
         iconColor: UIColor? = nil,
         extra: UIView? = nil,
         editable: Bool = false) {
        self.editable = editable
        super.init(frame: .zero)
        var image = UIImage(named: iconName)
        if image == nil {
            image = UIImage(systemName: iconName)
        }
        iconImage.image = image?.withTintColor(iconColor ?? .appTitle, renderingMode: .alwaysOriginal)
        titleLabel.text = title
        self.descriptionView = descriptionView
        extraView = extra
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal let contentView = UIView().enableAutoLayout()

    var onEdit: () -> Void = { }

    @objc private func didTapOnEditButton() {
        onEdit()
    }

    internal func setupLayout() {
        if let descriptionView = descriptionView {
            NSLayoutConstraint.activate([
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor),

                descriptionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
                descriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                descriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                descriptionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
                contentView.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            iconImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            contentView.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 25),

            topAnchor.constraint(equalTo: contentView.topAnchor, constant: -12),
            bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 12)
        ])

        if let extraView = extraView {
            addSubview(extraView)

            NSLayoutConstraint.activate([
                extraView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                extraView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            ])
        }

        if editable {
            addSubview(editIcon)
            NSLayoutConstraint.activate([
                editIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                editIcon.topAnchor.constraint(equalTo: topAnchor),
                contentView.trailingAnchor.constraint(equalTo: editIcon.leadingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            ])
        }
    }

    private func configure() {
        enableAutoLayout()

        addSubview(iconImage)
        contentView.addSubview(titleLabel)
        if let descriptionView = descriptionView {
            contentView.addSubview(descriptionView)
        }
        addSubview(contentView)
        setupLayout()
    }
}
