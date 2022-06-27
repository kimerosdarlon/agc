//
//  RadiusDrawingHeaderView.swift
//  CAD
//
//  Created by Samir Chaves on 03/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import MapKit

protocol RadiusDrawingHeaderDelegate: class {
    func didCancel()
    func didFinish()
}

class RadiusDrawingHeaderView: UIStackView {
    weak var delegate: RadiusDrawingHeaderDelegate?
    private let cancelBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancelar", for: .normal)
        btn.setTitleColor(.appTitle, for: .normal)
        btn.addTarget(self, action: #selector(didTapOnCancelBtn), for: .touchUpInside)
        return btn
    }()

    private let doneBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Concluir", for: .normal)
        btn.setTitleColor(.appBlue, for: .normal)
        btn.addTarget(self, action: #selector(didTapOnDoneBtn), for: .touchUpInside)
        return btn
    }()

    @objc private func didTapOnCancelBtn() {
        delegate?.didCancel()
    }

    @objc private func didTapOnDoneBtn() {
        delegate?.didFinish()
    }

    private let titleLabel = UILabel.build(withSize: 14, weight: .bold, color: .appTitle, alignment: .center, text: "Filtro Espacial")

    override func didMoveToSuperview() {
        axis = .horizontal
        distribution = .fillProportionally
        alignment = .center
        spacing = 8
        layer.cornerRadius = 8
        backgroundColor = .appBackground
        addArrangedSubview(cancelBtn.width(80).height(60))
        addArrangedSubview(titleLabel)
        addArrangedSubview(doneBtn.width(80).height(60))
    }
}
