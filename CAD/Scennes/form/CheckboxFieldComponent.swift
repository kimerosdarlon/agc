//
//  CheckboxFieldComponent.swift
//  CAD
//
//  Created by Samir Chaves on 14/04/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import Combine
import UIKit

class CheckboxFieldComponent: UIView, FormField {
    typealias Value = String?

    internal var type: FormFieldType = .checkbox
    private var path: CurrentValueSubject<String?, Never>?
    private let checkbox = Checkbox().enableAutoLayout()
    private let label = UILabel.build(withSize: 14)
    private var subscriptions = Set<AnyCancellable>()
    private let fieldName: String
    var valueWhenChecked: String?
    var valueWhenUnchecked: String = ""
    var labelWhenChecked: String?
    var onChange: () -> Void = { }

    var isChecked: Bool = false {
        didSet {
            checkbox.isChecked = isChecked
        }
    }

    init(label: String, fieldName: String) {
        self.fieldName = fieldName
        super.init(frame: .zero)

        self.label.text = label
        checkbox.delegate = self
        self.path = .init(nil)

        self.path?.sink(receiveValue: { newValue in
            guard let newValue = newValue,
                  let valueWhenChecked = self.valueWhenChecked,
                  !newValue.isEmpty else { return }
            garanteeMainThread {
                if newValue == valueWhenChecked && !self.isChecked {
                    self.isChecked = true
                } else if newValue == self.valueWhenUnchecked && self.isChecked {
                    self.isChecked = false
                }
            }
        }).store(in: &self.subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        let padding: CGFloat = 10
        addSubview(checkbox)
        addSubview(label)

        enableAutoLayout()
        height(40)

        checkbox.awakeFromNib()
        checkbox.handlerView = label
        checkbox.height(20).width(20)
        label.height(25)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleCheck))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),

            label.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @objc private func toggleCheck() {
        isChecked = !isChecked
    }

    func getHeight() -> CGFloat {
        50
    }

    func isFilled() -> Bool {
        checkbox.isChecked
    }

    func clear() {
        isChecked = false
    }

    func getUserInput() -> String? {
        checkbox.isChecked ? labelWhenChecked : nil
    }

    func getTitle() -> String {
        fieldName
    }

    func getSubject() -> CurrentValueSubject<Value, Never>? {
        self.path
    }

    func setSubject(_ subject: CurrentValueSubject<Value, Never>) {
        self.path = subject
    }
}

extension CheckboxFieldComponent: CheckboxDelegate {
    func didChanged(checkbox: Checkbox) {
        onChange()
        if checkbox.isChecked {
            path?.send(valueWhenChecked)
        } else {
            path?.send(valueWhenUnchecked)
        }
    }
}
