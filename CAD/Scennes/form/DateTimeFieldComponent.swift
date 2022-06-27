//
//  DateTimeFieldComponent.swift
//  CAD
//
//  Created by Samir Chaves on 05/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import Combine

class CustomTextField: UITextField {
    var onBlur: () -> Void = { }
    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            if isEnabled {
                alpha = 1
            } else {
                alpha = 0.6
            }
        }
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        onBlur()
        return true
    }
}

private func buildNumberField(enabled: Bool = true) -> CustomTextField {
    let textField = CustomTextField()
    textField.backgroundColor = .appBackgroundCell
    textField.tintColor = .appBlue
    textField.textColor = .appCellLabel
    let paddingView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 20))
    textField.layer.cornerRadius = 5
    textField.leftView = paddingView
    textField.leftViewMode = .always
    textField.isEnabled = enabled
    textField.enableAutoLayout()
    textField.height(40)
    textField.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    textField.keyboardType = .numberPad
    return textField
}

class DateTimeFieldComponent: UIStackView, UIPickerViewDelegate, FormField {
    typealias Value = String?

    internal var type: FormFieldType = .datetime
    private var path: CurrentValueSubject<String?, Never>?
    private var fieldFilled = false
    private var initialHours: Int
    private var initialMinutes: Int
    private let dateMask = TextFieldMask(patterns: ["##/##/####"])
    private let timeMask = TextFieldMask(patterns: ["##:##"])

    private let fieldsContainer = UIView(frame: .zero).enableAutoLayout().height(40)
    var dateField: UIDatePicker = {
        let dateField = UIDatePicker()
        if #available(iOS 13.4, *) {
            dateField.preferredDatePickerStyle = .wheels
        }
        dateField.datePickerMode = .date
        dateField.addTarget(self, action: #selector(dateTimeHasChanged), for: .valueChanged)
        return dateField.enableAutoLayout()
    }()

    var timeField: UIDatePicker = {
        let dateField = UIDatePicker()
        if #available(iOS 13.4, *) {
            dateField.preferredDatePickerStyle = .wheels
        }
        dateField.datePickerMode = .time
        dateField.addTarget(self, action: #selector(dateTimeHasChanged), for: .valueChanged)
        return dateField.enableAutoLayout()
    }()

    var textDateField: CustomTextField = buildNumberField()
    var textTimeField: CustomTextField = buildNumberField(enabled: false)

    var label: UILabel = UILabel.build(withSize: 14, color: .appCellLabel, alignment: .left).enableAutoLayout().height(15)

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
        endEditing(true)
        endInputEditing(fill: true)
    }

    private func endInputEditing(fill: Bool = false) {
        var date = parseDateTextInput()
        if date == nil && fill {
            date = Date()
        }
        if let date = date {
            dateField.date = date
            if let time = parseTimeTextInput() {
                timeField.date = time
            }
            textTimeField.isEnabled = true
            dateTimeHasChanged()
        } else {
            textTimeField.isEnabled = false
        }
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

    private var timeInputControl: UISegmentedControl = {
        let items = ["keyboard", "clock"].map { iconName in
            UIImage(systemName: iconName)?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        }
        let control = UISegmentedControl(items: items.compactMap { $0 }).enableAutoLayout()
        control.selectedSegmentTintColor = .appBlue
        control.selectedSegmentIndex = 0
        return control
    }()

    private func updateControlColors(for control: UISegmentedControl, images: [String]) {
        images.enumerated().forEach { i, iconName in
            var image = UIImage(systemName: iconName)?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
            if control.selectedSegmentIndex == i {
                image = UIImage(systemName: iconName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            }
            control.setImage(image, forSegmentAt: i)
        }
    }

    private var dateInputAccessoryView: UIView!
    private var timeInputAccessoryView: UIView!

    func getTitle() -> String {
        return self.label.text?.replacingOccurrences(of: ":", with: "") ?? ""
    }

    init(label: String, initialHours: Int = 0, initialMinutes: Int = 0) {
        self.initialHours = initialHours
        self.initialMinutes = initialMinutes
        super.init(frame: .zero)
        self.dateInputAccessoryView = getInputAccessoryView(control: dateInputControl, input: textDateField)
        self.timeInputAccessoryView = getInputAccessoryView(control: timeInputControl, input: textTimeField)
        dateField.date = Calendar.current.date(bySettingHour: initialHours, minute: initialMinutes, second: 0, of: Date())!
        self.label.text = label
        self.textDateField.placeholder = "00/00/0000"
        self.textDateField.addTarget(self, action: #selector(dateTextHasChanged(_:)), for: .editingChanged)
        self.textTimeField.placeholder = "00:00"
        self.textTimeField.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        axis = .vertical
        spacing = 12
        textDateField.onBlur = {
            self.endInputEditing()
        }
        textTimeField.onBlur = {
            self.endInputEditing()
        }
        updateControlColors(for: dateInputControl, images: ["keyboard", "calendar"])
        updateControlColors(for: timeInputControl, images: ["keyboard", "clock"])
        self.path = .init(nil)
    }

    @objc private func dateTextHasChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        if text.count == 10 && parseDateTextInput() != nil {
            endInputEditing()
            textTimeField.becomeFirstResponder()
            textTimeField.text = ""
        } else {
            textTimeField.isEnabled = false
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        fieldsContainer.addSubview(textDateField)
        fieldsContainer.addSubview(textTimeField)
        addArrangedSubview(label)
        addArrangedSubview(fieldsContainer)
        fieldsContainer.width(self)

        NSLayoutConstraint.activate([
            textDateField.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor),
            textDateField.trailingAnchor.constraint(equalTo: textTimeField.leadingAnchor, constant: -1),
            textTimeField.trailingAnchor.constraint(equalTo: fieldsContainer.trailingAnchor),
            textTimeField.centerYAnchor.constraint(equalTo: textDateField.centerYAnchor),
            fieldsContainer.bottomAnchor.constraint(equalTo: textDateField.bottomAnchor, constant: 0),
            textTimeField.widthAnchor.constraint(equalToConstant: 120)
        ])

        let clearDateBtn = textDateField.addClearButton()
        let dateBtn = textDateField.buildLeftButton(iconName: "calendar", color: UIColor.appTitle.withAlphaComponent(0.4))
        dateBtn.addTarget(self, action: #selector(didTapOnDateBtn), for: .touchUpInside)
        dateInputControl.addTarget(self, action: #selector(dateInputTypeChanged(_:)), for: .valueChanged)
        textDateField.inputAccessoryView = dateInputAccessoryView
        textDateField.delegate = dateMask

        clearDateBtn.isUserInteractionEnabled = true
        let tapInDate = UITapGestureRecognizer(target: self, action: #selector(didClickOnDateClearButton))
        clearDateBtn.addGestureRecognizer(tapInDate)

        let clearTimeBtn = textTimeField.addClearButton()
        let timeBtn = textTimeField.buildLeftButton(iconName: "clock", color: UIColor.appTitle.withAlphaComponent(0.4))
        timeBtn.addTarget(self, action: #selector(didTapOnTimeBtn), for: .touchUpInside)
        timeInputControl.addTarget(self, action: #selector(timeInputTypeChanged(_:)), for: .valueChanged)
        textTimeField.inputAccessoryView = timeInputAccessoryView
        textTimeField.delegate = timeMask

        clearTimeBtn.isUserInteractionEnabled = true
        let tapInTime = UITapGestureRecognizer(target: self, action: #selector(didClickOnTimeClearButton))
        clearTimeBtn.addGestureRecognizer(tapInTime)
    }

    private func setDateInputView(_ inputView: UIView?) {
        textDateField.inputView = inputView
        textDateField.reloadInputViews()
    }

    private func setTimeInputView(_ inputView: UIView?) {
        textTimeField.inputView = inputView
        textTimeField.reloadInputViews()
    }

    @objc func dateInputTypeChanged(_ sender: UISegmentedControl) {
        updateControlColors(for: dateInputControl, images: ["keyboard", "calendar"])
        switch sender.selectedSegmentIndex {
        case 1:
            setDateInputView(dateField)
            if let parsedDate = parseDateTextInput() {
                dateField.date = parsedDate
            } else {
                textDateField.text = ""
            }
        default:
            setDateInputView(nil)
        }
    }

    @objc func timeInputTypeChanged(_ sender: UISegmentedControl) {
        updateControlColors(for: timeInputControl, images: ["keyboard", "clock"])
        switch sender.selectedSegmentIndex {
        case 1:
            setTimeInputView(timeField)
            if let parsedTime = parseTimeTextInput() {
                timeField.date = parsedTime
            } else {
                textTimeField.text = ""
            }
        default:
            setTimeInputView(nil)
        }
    }

    @objc func didTapOnDateBtn() {
        textDateField.becomeFirstResponder()
        dateInputControl.selectedSegmentIndex = 1
        setDateInputView(dateField)
    }

    @objc func didTapOnTimeBtn() {
        textTimeField.becomeFirstResponder()
        timeInputControl.selectedSegmentIndex = 1
        setTimeInputView(timeField)
    }

    private func parseDateTextInput() -> Date? {
        return textDateField.text?.toDate(format: "dd/MM/yyyy")
    }

    private func parseTimeTextInput() -> Date? {
        return textTimeField.text?.toDate(format: "HH:mm")
    }

    @objc func dateTimeHasChanged(_ sender: UIDatePicker? = nil) {
        let date = dateField.date
        var dateTime = Date()
        textTimeField.isEnabled = true

        if let timeText = textTimeField.text, !timeText.isEmpty {
            let hour = Calendar.current.component(.hour, from: timeField.date)
            let minute = Calendar.current.component(.minute, from: timeField.date)
            dateTime = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
        } else if (sender != nil && sender!.datePickerMode == .date) || sender == nil {
            dateTime = Calendar.current.date(bySettingHour: initialHours, minute: initialMinutes, second: 0, of: date)!
        }
        updateDateTime(to: dateTime)
    }

    @objc func didClickOnDateClearButton() {
//        if dateInputControl.selectedSegmentIndex != 0 {
            self.endEditing(true)
//        }
        textDateField.text = ""
        textTimeField.text = ""
        textTimeField.isEnabled = false
        fieldFilled = false
        path?.send("")
    }

    @objc func didClickOnTimeClearButton() {
        if timeInputControl.selectedSegmentIndex != 0 {
            self.endEditing(true)
        }
        textTimeField.text = ""
        if let text = textDateField.text, !text.isEmpty, timeInputControl.selectedSegmentIndex != 0 {
            dateTimeHasChanged()
        }
    }
}

extension DateTimeFieldComponent {
    func clear() {
        didClickOnDateClearButton()
    }

    func getUserInput() -> String? {
        return textDateField.text != nil ? "\(textDateField.text!) \(textTimeField.text ?? "")" : nil
    }

    func updateDateTime(to datetime: Date) {
        let formattedDate = datetime.format(to: "dd/MM/yyyy")
        let formattedTime = datetime.format(to: "HH:mm")
        textDateField.text = formattedDate
        textTimeField.text = formattedTime
        dateField.date = datetime
        timeField.date = datetime
        if let text = textDateField.text, !text.isEmpty {
            fieldFilled = true
        } else {
            fieldFilled = false
        }
        path?.send(datetime.format(to: "yyyy-MM-dd'T'HH:mm:ss.000'Z'"))
    }

    func getHeight() -> CGFloat { 55 + 20 }

    func isFilled() -> Bool { fieldFilled }

    func getSubject() -> CurrentValueSubject<Value, Never>? {
        self.path
    }

    func setSubject(_ subject: CurrentValueSubject<Value, Never>) {
        self.path = subject
    }
}
