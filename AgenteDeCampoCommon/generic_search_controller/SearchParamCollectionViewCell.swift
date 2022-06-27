//
//  SearchParamCollectionViewCell.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 01/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class SearchParamCollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: SearchParamCollectionViewCell.self)

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func configure(with text: String) {
        var str = text.uppercased()
        if text.isCPF {
            str = text.apply(pattern: AppMask.cpfMask, replacmentCharacter: "#")
        } else if text.isCNPJ {
            str = text.apply(pattern: AppMask.cnpjMask, replacmentCharacter: "#")
        }
        let component = SearchTermComponent(text: str)
        contentView.addSubview(component)
        component.enableAutoLayout()
        NSLayoutConstraint.activate([
            component.topAnchor.constraint(equalTo: contentView.topAnchor),
            component.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            component.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            component.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        component.layer.cornerRadius = self.frame.height/2
        component.layer.masksToBounds = true
        component.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
