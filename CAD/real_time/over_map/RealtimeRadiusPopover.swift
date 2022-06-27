//
//  RealtimeRadiusPopover.swift
//  CAD
//
//  Created by Samir Chaves on 22/04/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

protocol RealtimeRadiusPopoverDelegate: class {
    func didChangeRadius(_ radius: CGFloat)
    func didTapOnDrawButton(_ radius: CGFloat)
}

class RealtimeRadiusPopover: UIView {
    weak var delegate: RealtimeRadiusPopoverDelegate?
    private let titleLabel = UILabel.build(withSize: 15, weight: .bold, color: .appTitle, text: "Filtro espacial")
    private let suggestionsTags = TagsFieldComponent(tags: [
        (key: "1000", value: "1 km"),
        (key: "5000", value: "5 km"),
        (key: "15000", value: "15 km"),
        (key: "50000", value: "50 km")
    ], multipleChoice: false).enableAutoLayout()
    private let radiusField = TextFieldComponent(placeholder: "De 100m a 50.000m", label: "Determine a distância em metros", keyboardType: .decimalPad).enableAutoLayout()
    private var initialPosition: CGPoint = .zero
    private let minRadius: CGFloat = 100
    private let maxRadius: CGFloat = 50000
    private var radiusValue: CGFloat = 0 {
        didSet {
            var treatedRadius = radiusValue < minRadius ? minRadius : radiusValue
            treatedRadius = treatedRadius > maxRadius ? maxRadius : treatedRadius
            delegate?.didChangeRadius(treatedRadius)
        }
    }
    private let drawButton: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        let icon = UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        btn.setTitleColor(.appTitle, for: .normal)
        btn.setTitleColor(UIColor.appTitle.withAlphaComponent(0.7), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("Reposicionar raio", for: .normal)
        btn.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 5)
        btn.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 0)
        btn.setImage(icon, for: .normal)
        btn.layer.cornerRadius = 5
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.appTitle.cgColor
        btn.backgroundColor = .appBackgroundCell
        btn.addTarget(self, action: #selector(didTapOnDrawButton), for: .touchUpInside)
        return btn
    }()

    @objc private func didTapOnDrawButton() {
        self.endEditing(true)
        delegate?.didTapOnDrawButton(radiusValue)
        suggestionsTags.clear()
        radiusField.clear()
        isOpen = false
    }

    var isOpen: Bool = false {
        didSet {
            if isOpen {
                show()
            } else {
                hide()
            }
        }
    }

    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 5
        layer.shadowPath = .none
        layer.shadowColor = UIColor.black.cgColor.copy(alpha: 0.05)
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        backgroundColor = .appBackground
        alpha = 0

        addSubview(titleLabel)
        addSubview(suggestionsTags)
        addSubview(radiusField)
        addSubview(drawButton)
        radiusField.textField.rightView = UILabel.build(
            withSize: 14,
            weight: .bold,
            color: UIColor.appTitle.withAlphaComponent(0.6),
            text: " m "
        ).enableAutoLayout()
        setupLayout()

        let size = bounds.size
        transform = CGAffineTransform.identity.translatedBy(x: size.width / 2, y: -size.height / 2).scaledBy(x: 0.001, y: 0.001)

        radiusField.textField.delegate = self
        suggestionsTags.onSelect = { (selected, _) in
            if let radius = self.getFloat(from: selected.key), self.radiusValue != radius {
                self.radiusValue = radius
                self.radiusField.clear()
            }
        }
    }

    private func setupLayout() {
        let padding: CGFloat = 15
        drawButton.height(40)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            suggestionsTags.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            suggestionsTags.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            suggestionsTags.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            radiusField.topAnchor.constraint(equalTo: suggestionsTags.bottomAnchor, constant: padding),
            radiusField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            radiusField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            drawButton.topAnchor.constraint(equalTo: radiusField.bottomAnchor, constant: 1.5 * padding),
            drawButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            drawButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            bottomAnchor.constraint(equalTo: drawButton.bottomAnchor, constant: padding)
        ])
    }

    private func hide() {
        let size = bounds.size
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity.translatedBy(x: size.width / 2, y: -size.height / 2).scaledBy(x: 0.001, y: 0.001)
            self.alpha = 0
        }
    }

    private func show() {
        suggestionsTags.update()
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
            self.alpha = 1
        }
    }

    private func getFloat(from str: String) -> CGFloat? {
        if let n = NumberFormatter().number(from: str) {
            return CGFloat(truncating: n)
        }
        return nil
    }

    func toggleVisibility() {
        isOpen = !isOpen
    }
}

extension RealtimeRadiusPopover: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text,
           let radius = getFloat(from: text) {
            radiusValue = radius
            suggestionsTags.clear()
        }
    }
}
