//
//  TextFieldComponent.swift
//  CAD
//
//  Created by Ramires Moreira on 11/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
import Combine

enum TextFieldType {
    case cpf
    case plate
    case plain
}

class TextFieldComponent: UIStackView, UITextFieldDelegate, FormField {
    typealias Value = String?

    var type: FormFieldType = .text
    var textValidationType: TextFieldType = .plain {
        didSet {
            switch textValidationType {
            case .cpf:
                textMask = TextFieldMask(patterns: ["###.###.###-##"])
                self.formater = { string in
                    cpfMask(string)
                }
            case .plate:
                textMask = TextFieldMask(patterns: ["###-####"])
            default:
                textMask = nil
            }
        }
    }
    private var path: CurrentValueSubject<String?, Never>?
    var formater: ((String?) -> String?)?
    var showFeedbackForTypeValidation = false
    private var textMask: TextFieldMask?
    private var placeholder = ""
    private let forSelect: Bool
    private var subscription: AnyCancellable?
    private let showLabel: Bool

    var state: FormFieldState {
        didSet {
            switch state {
            case .loading:
                textField.placeholder = "Carregando..."
                textField.alpha = 0.7
                textField.isUserInteractionEnabled = false
            case .notFound:
                textField.placeholder = "Sem resultados"
                textField.alpha = 0.7
                textField.isUserInteractionEnabled = false
            case .ready:
                textField.placeholder = placeholder
                textField.alpha = 1
                textField.isUserInteractionEnabled = true
            case .error(let message):
                textField.placeholder = ""
                textField.text = message
                textField.alpha = 0.7
                textField.textColor = .appRed
                textField.isUserInteractionEnabled = false
            }
        }
    }

    var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .appBackgroundCell
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 20))
        textField.layer.cornerRadius = 5
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.enableAutoLayout()
        textField.height(40)
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

    private let validationLabel = UILabel.build(withSize: 12, color: .appWarning)

    var fieldName: String

    init(placeholder: String,
         label: String,
         fieldName: String? = nil,
         keyboardType: UIKeyboardType = .alphabet,
         formater: ((String?) -> String?)? = nil,
         type: TextFieldType = .plain,
         initialState: FormFieldState = .ready,
         forSelect: Bool = false,
         showLabel: Bool = true) {

        self.forSelect = forSelect
        self.formater = formater
        self.fieldName = fieldName ?? label
        self.state = initialState
        self.placeholder = placeholder
        self.showLabel = showLabel

        super.init(frame: .zero)

        self.textField.placeholder = placeholder
        self.textField.keyboardType = keyboardType
        self.label.text = label
        axis = .vertical
        spacing = 8

        textField.delegate = self

        textValidationType = type

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

    private func showValidationWarning() {
        if let warningImage = UIImage(systemName: "exclamationmark.triangle.fill"),
           textValidationType == .cpf {
            validationLabel.isHidden = false
            let attachmentIcon = NSTextAttachment(image: warningImage)
            let attachmentString = NSMutableAttributedString(attachment: attachmentIcon)
            attachmentString.append(NSAttributedString(string: "Aviso: o valor informado não é um CPF válido"))
            validationLabel.attributedText = attachmentString
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }

    private func hideValidationWarning() {
        validationLabel.isHidden = true
        validationLabel.text = nil
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if !forSelect {
            path?.send(formatedText())
        }

        if let text = textField.text,
           textValidationType == .cpf,
           text.matches(in: AppRegex.cpfPattern) {
            let formattedText = text.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ".", with: "")
            if !formattedText.isCPF {
                showValidationWarning()
            } else {
                hideValidationWarning()
            }
        } else {
            hideValidationWarning()
        }
        textMask?.textFieldDidChangeSelection(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let response = textMask?.textFieldShouldReturn(textField) {
            return response
        }
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let response = textMask?.textField(textField, shouldChangeCharactersIn: range, replacementString: string) {
            return response
        }
        return true
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if showLabel {
            addArrangedSubview(self.label)
        }
        addArrangedSubview(textField)
        addArrangedSubview(validationLabel)
        setCustomSpacing(5, after: textField)
    }
}

extension TextFieldComponent {
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
