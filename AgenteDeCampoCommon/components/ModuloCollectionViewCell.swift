//
//  ModuloCollectionViewCell.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 23/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
public class ModuloCollectionViewCell: UICollectionViewCell {

    public static let identifier = String(describing: ModuloCollectionViewCell.self)

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.enableAutoLayout()
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let displayLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = .appCollectionCell
        label.textColor = .label
        return label
    }()

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(imageView)
        addSubview(displayLabel)
        backgroundColor = .appBackgroundCell
        layer.masksToBounds = true
        layer.cornerRadius = 8

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            imageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            displayLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            displayLabel.topAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1)
        ])
    }

    public func configure(with model: Module) {
        imageView.image = UIImage(named: model.imageName)
        displayLabel.text = model.name
    }
}
