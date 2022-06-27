//
//  DateFieldComponent.swift
//  CAD
//
//  Created by Samir Chaves on 14/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import UIKit
import Combine
import AgenteDeCampoCommon

class DateFieldComponent: UIStackView, UIPickerViewDelegate, FormField {
    typealias Value = String?

    internal var type: FormFieldType = .date
    private var path: CurrentValueSubject<String?, Never>?
    private var subscription: AnyCancellable?
    private var fieldFilled = false
    private let dateMask = TextFieldMask(patterns: ["##/##/####"])
    private let showLabel: Bool

    private func getInputAccessoryView(control: UISegmentedControl, input: UITextInput) -> UIView {
        let view = UIView(frame: .init(x: 0, y: 0, width: 50, height: 45)).enableAutoLayout()
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(control)
        let okBtn = UIButton(type: .system).width(40).width(50).enableAutoLayout()
        okBtn.setTitle("OK", for: .normal)
        okBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        okBtn.setTitleColor(.appBlue, for: .normal)
        okBtn.addTarget(self, action: #selector(didClickOnOkButton), for: .touchUpInside)
        view.addSubview(okBtn)
        NSLayoutConstraint.activate([
            control.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            control.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            okBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            okBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        return view
    }

    @objc private func didClickOnOkButton() {
        self.endEditing(true)
    }

    private var dateInputControl: UISegmentedControl = {
        let items = ["keyboard", "calendar"].map { iconName in
            UIImage(systemName: iconName)?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        }
        let control = UISegmentedControl(items: items.compactMap { $0 }).enableAutoLayout()
        control.selectedSegmentTintColor = .appBlue
        control.selectedSegmentIndex = 0
        return control
    }()

    private func updateControlColors() {
        ["keyboard", "calendar"].enumerated().forEach { i, iconName in
            var image = UIImage(systemName: iconName)?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
            if dateInputControl.selectedSegmentIndex == i {
                image = UIImage(systemName: iconName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            }
            dateInputControl.setImage(image, forSegmentAt: i)
        }
    }

    private var dateInputAccessoryView: UIView!

    var dateField: UIDatePicker = {
        let dateField = UIDatePicker()
        if #available(iOS 13.4, *) {
            dateField.preferredDatePickerStyle = .wheels
        }
        dateField.datePickerMode = .date
        dateField.addTarget(self, action: #selector(dateIsChanged), for: .valueChanged)
        return dateField.enableAutoLayout()
    }()

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
        textField.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        textField.keyboardType = .numberPad
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

    init(label: String, showLabel: Bool = true) {
        self.showLabel = showLabel
        super.init(frame: .zero)
        self.dateInputAccessoryView = self.getInputAccessoryView(control: dateInputControl, input: textField)
        self.label.text = label
        textField.placeholder = "00/00/0000"
        axis = .vertical
        spacing = 8
        self.path = .init(nil)

        subscription = path?.sink(receiveValue: { newValue in
            guard let newValue = newValue,
                  !newValue.isEmpty,
                  let date = newValue.toDate(format: "yyyy-MM-dd") else {
                return
            }

            self.dateField.date = date
            self.textField.text = date.format(to: "dd/MM/yyyy")
        })
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        if showLabel {
            addArrangedSubview(self.label)
        }
        addArrangedSubview(textField)
        let clearBtn = textField.addClearButton()
        let dateBtn = textField.buildLeftButton(iconName: "calendar", color: UIColor.appTitle.withAlphaComponent(0.4), size: 40)
        dateBtn.addTarget(self, action: #selector(didTapOnDateBtn), for: .touchUpInside)
        dateInputControl.addTarget(self, action: #selector(dateInputTypeChanged(_:)), for: .valueChanged)
        textField.addTarget(self, action: #selector(dateTextHasChanged(_:)), for: .editingChanged)
        textField.inputAccessoryView = dateInputAccessoryView
        textField.delegate = dateMask

        clearBtn.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickOnClearButton))
        clearBtn.addGestureRecognizer(tap)

        updateControlColors()
    }

    @objc private func dateTextHasChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        if let parsedDate = parseDateTextInput(), text.count == 10 {
            updateDate(to: parsedDate)
        }
    }

    private func setDateInputView(_ inputView: UIView?) {
        textField.inputView = inputView
        textField.reloadInputViews()
    }

    @objc func didTapOnDateBtn() {
        textField.becomeFirstResponder()
        dateInputControl.selectedSegmentIndex = 1
        setDateInputView(dateField)
    }

    private func parseDateTextInput() -> Date? {
        return textField.text?.toDate(format: "dd/MM/yyyy")
    }

    @objc func dateInputTypeChanged(_ sender: UISegmentedControl) {
        updateControlColors()
        switch sender.selectedSegmentIndex {
        case 1:
            setDateInputView(dateField)
            if let parsedDate = parseDateTextInput() {
                dateField.date = parsedDate
            } else {
                textField.text = ""
            }
        default:
            setDateInputView(nil)
        }
    }

    @objc func dateIsChanged(sender: UIDatePicker) {
        self.updateDate(to: sender.date)
    }

    @objc func didClickOnClearButton() {
        self.endEditing(true)
        self.textIsChanged(to: "")
    }

    func getTitle() -> String {
        return self.label.text?.replacingOccurrences(of: ":", with: "") ?? ""
    }

    func getUserInput() -> String? {
        return textField.text
    }

    func updateDate(to date: Date) {
        let formattedDate = date.format(to: "dd/MM/yyyy")
        self.textIsChanged(to: formattedDate)
    }

    func textIsChanged(to text: String) {
        textField.text = text
        if let text = textField.text, !text.isEmpty {
            fieldFilled = true
        } else {
            fieldFilled = false
        }
        path?.send(textField.text?.split(separator: "/").reversed().joined(separator: "-"))
    }

    func clear() {
        textField.text = ""
        fieldFilled = false
        path?.send(textField.text)
    }

    func getHeight() -> CGFloat {
        55 + 20
    }

    func isFilled() -> Bool {
        fieldFilled
    }

    func getSubject() -> CurrentValueSubject<Value, Never>? {
        self.path
    }

    func setSubject(_ subject: CurrentValueSubject<Value, Never>) {
        self.path = subject
    }
}
