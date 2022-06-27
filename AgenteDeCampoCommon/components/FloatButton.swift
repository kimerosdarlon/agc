//
//  FloatButton.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 10/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class FloatButton: UIButton {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        let size: CGFloat = 60
        backgroundColor = .appBlue
        enableAutoLayout().width(size).height(size)
        let plusImage = UIImage(systemName: "plus")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(font: UIFont.robotoRegular.withSize(16), scale: .large) )
        setImage(plusImage, for: .normal)
        contentMode = .center
        layer.cornerRadius = size/2
        layer.masksToBounds = true
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
