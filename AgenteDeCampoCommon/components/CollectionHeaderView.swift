//
//  CollectionHeaderView.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 23/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class CollectionHeaderView: UICollectionReusableView {

    public static let identifier = String(describing: CollectionHeaderView.self)

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize(14)
        label.textColor = .appLightGray
        label.enableAutoLayout()
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.text = "Consulta por módulo"
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .appBackground
        enableAutoLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
