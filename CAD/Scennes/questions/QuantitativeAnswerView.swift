//
//  QuantitativeAnswerView.swift
//  CAD
//
//  Created by Samir Chaves on 13/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class QuantitativeAnswerView: UIView {

    weak var delegate: QuestionAnswerDelegate?
    private var answer: Float?

    private let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.textField.withAlphaComponent(0.1)
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        textField.layer.cornerRadius = 5
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.enableAutoLayout()
        textField.keyboardType = .decimalPad
        textField.placeholder = "Ex: 0000000"
        textField.font = UIFont.systemFont(ofSize: 18)
        return textField
    }()

    func configure(withDelegate delegate: QuestionAnswerDelegate) {
        addSubview(textField)
        self.delegate = delegate

        textField.delegate = self
        textField.height(55)

        enableAutoLayout()

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomAnchor.constraint(equalTo: textField.bottomAnchor)
        ])
    }
}

extension QuantitativeAnswerView: QuestionAnswer, UITextFieldDelegate {
    func shouldShowJustificativeCheckbox() -> Bool {
        true
    }

    func shouldShowJustificativeField() -> Bool {
        false
    }

    func didSelectedBlankOption() {
        textField.isEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.textField.alpha = 0.5
        }
    }

    func didUnselectedBlankOption() {
        textField.isEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.textField.alpha = 1
        }
    }

    func getAnswer() -> AnswerValue? { answer.map { AnswerValue.quantitative($0) } }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isNotEmpty {
            answer = (textField.text as NSString?)?.floatValue
        } else {
            answer = Float.nan
        }

        delegate?.didAnswered(answer: answer as Any)
    }
}
