//
//  TextualAnswerView.swift
//  CAD
//
//  Created by Samir Chaves on 13/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class TextualAnswerView: UIView {
    weak var delegate: QuestionAnswerDelegate?
    private var heightConstraint: NSLayoutConstraint!
    private var answer: String?

    private let textField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = UIColor.textField.withAlphaComponent(0.1)
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        textField.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        textField.layer.cornerRadius = 5
        textField.enableAutoLayout()
        textField.keyboardType = .alphabet
        textField.autocorrectionType = .no
        textField.font = UIFont.systemFont(ofSize: 15)
        return textField
    }()

    func configure(withDelegate delegate: QuestionAnswerDelegate) {
        addSubview(textField)
        self.delegate = delegate
        enableAutoLayout()

        heightConstraint = heightAnchor.constraint(equalToConstant: 200)
        heightConstraint.isActive = true
        textField.delegate = self

        textField.fillSuperView()
    }
}

extension TextualAnswerView: QuestionAnswer, UITextViewDelegate {

    func shouldShowJustificativeCheckbox() -> Bool {
        true
    }

    func shouldShowJustificativeField() -> Bool {
        false
    }

    func getAnswer() -> AnswerValue? { answer.map { AnswerValue.textual($0) } }

    func didSelectedBlankOption() {
        self.heightConstraint?.constant = 20
        self.textField.isEditable = false
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            self.textField.alpha = 0.5
        }
    }

    func didUnselectedBlankOption() {
        self.heightConstraint?.constant = 200
        self.textField.isEditable = true
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            self.textField.alpha = 1
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        answer = textView.text
        delegate?.didAnswered(answer: answer)
    }
}
