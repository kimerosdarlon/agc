//
//  TextAreaFieldComponent.swift
//  CAD
//
//  Created by Samir Chaves on 21/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import Combine
import UIKit

class TextAreaFieldComponent: UIStackView, UITextViewDelegate, FormField {
    var type: FormFieldType = .textarea

    typealias Value = String?

    private var path: CurrentValueSubject<String?, Never>?
    var formater: ((String?) -> String?)?
    private var subscription: AnyCancellable?
    private let showLabel: Bool

    var state: FormFieldState {
        didSet {
            switch state {
            case .loading:
                textField.alpha = 0.7
                textField.isUserInteractionEnabled = false
            case .notFound:
                textField.alpha = 0.7
                textField.isUserInteractionEnabled = false
            case .ready:
                textField.alpha = 1
                textField.isUserInteractionEnabled = true
            case .error(let message):
                textField.text = message
                textField.alpha = 0.7
                textField.textColor = .appRed
                textField.isUserInteractionEnabled = false
            }
        }
    }

    var textField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = .appBackgroundCell
        textField.tintColor = .appBlue
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = .appCellLabel
        textField.contentInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        textField.layer.cornerRadius = 5
        textField.enableAutoLayout()
        textField.height(150)
        return textField
    }()

    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoMedium.withSize(14)
        label.textColor = .appCellLabel
        label.textAlignment = .left
        label.enableAutoLayout()
        label.height(15)
        return label
    }()

    var fieldName: String

    init(label: String,
         fieldName: String? = nil,
         keyboardType: UIKeyboardType = .alphabet,
         initialState: FormFieldState = .ready,
         showLabel: Bool = true) {

        self.fieldName = fieldName ?? label
        self.state = initialState
        self.showLabel = showLabel

        super.init(frame: .zero)

        self.textField.keyboardType = keyboardType
        self.label.text = label
        axis = .vertical
        spacing = 8

        textField.delegate = self

        self.path = .init(nil)
        subscription = self.path?.sink(receiveValue: { newValue in
            self.textField.text = newValue
        })
    }

    func getTitle() -> String {
        return fieldName.replacingOccurrences(of: ":", with: "")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func formatedText() -> String? {
        return formater?(textField.text) ?? textField.text
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        path?.send(formatedText())
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if showLabel {
            addArrangedSubview(self.label)
        }
        addArrangedSubview(textField)
    }
}

extension TextAreaFieldComponent {
    func getHeight() -> CGFloat { 55 + 20 }

    func getUserInput() -> String? { textField.text }

    func clear() {
        textField.text = ""
        path?.send(textField.text)
    }

    func isFilled() -> Bool {
        textField.text != nil && !textField.text!.isEmpty
    }

    func getSubject() -> CurrentValueSubject<Value, Never>? {
        return self.path
    }

    func setSubject(_ subject: CurrentValueSubject<Value, Never>) {
        self.path = subject
    }
}
