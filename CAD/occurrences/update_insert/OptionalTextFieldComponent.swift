//
//  OptionalTextFieldComponent.swift
//  CAD
//
//  Created by Samir Chaves on 22/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import Combine
import AgenteDeCampoCommon
import UIKit

class OptionalTextFieldComponent: UIStackView, UITextFieldDelegate, FormField {
    var type: FormFieldType = .text

    typealias Value = String?

    private let textField: TextFieldComponent
    private let checkbox: CheckboxFieldComponent

    private var path: CurrentValueSubject<String?, Never>?

    private var subscriptions = Set<AnyCancellable>()

    init(placeholder: String,
         label: String,
         checkboxLabel: String,
         defaultText: String,
         fieldName: String? = nil,
         keyboardType: UIKeyboardType = .alphabet,
         showLabel: Bool = true) {

        checkbox = CheckboxFieldComponent(label: checkboxLabel, fieldName: "")
        textField = TextFieldComponent(placeholder: placeholder,
                                       label: label,
                                       fieldName: fieldName,
                                       keyboardType: keyboardType,
                                       type: .plain,
                                       showLabel: showLabel)

        checkbox.valueWhenChecked = defaultText

        super.init(frame: .zero)

        self.path = textField.getSubject()

        checkbox.getSubject()?
            .sink(receiveValue: { checkboxValue in
                if let checkboxValue = checkboxValue, !checkboxValue.isEmpty {
                    self.setOptional(true)
                } else {
                    self.setOptional(false)
                }
            })
            .store(in: &subscriptions)

        axis = .vertical
        spacing = 5
    }

    private func setOptional(_ isOptional: Bool) {
        if isOptional {
            self.textField.alpha = 0.7
            self.textField.isUserInteractionEnabled = false
            self.path?.send(checkbox.valueWhenChecked)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addArrangedSubview(textField)
        addArrangedSubview(checkbox)
    }
}

extension OptionalTextFieldComponent {
    func getHeight() -> CGFloat { 55 + 20 }

    func getUserInput() -> String? { path?.value }

    func clear() {
        path?.send("")
    }

    func isFilled() -> Bool {
        guard let path = path else { return false }
        return path.value != nil && !path.value!.isEmpty
    }

    func getSubject() -> CurrentValueSubject<Value, Never>? {
        return path
    }

    func setSubject(_ subject: CurrentValueSubject<Value, Never>) {
        self.path = subject
    }

    func getTitle() -> String {
        return textField.getTitle()
    }
}

