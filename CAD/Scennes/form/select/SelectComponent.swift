//
//  SelectComponent.swift
//  CAD
//
//  Created by Samir Chaves on 03/10/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import UIKit
import Combine

class SelectComponent<K: Hashable>: UIView, FormField {
    typealias Value = K?

    internal var type: FormFieldType = .select
    private var dynamicSearch: DynamicSearchViewController<K>?
    private var subscription: AnyCancellable?
    private var showLabel = true

    fileprivate let titleLabel = UILabel.build(withSize: 14, weight: .medium)
    fileprivate let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .appBackgroundCell
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        textField.keyboardType = .default
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 20))
        textField.layer.cornerRadius = 5
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.enableAutoLayout()
        return textField
    }()

    private let parentViewController: UIViewController
    fileprivate var selectedTag: SelectedTag<K>?
    fileprivate var path = CurrentValueSubject<K?, Never>(nil)
    fileprivate let label: String
    fileprivate let canClean: Bool

    // Events closures
    var onChangeQuery = { (_: String, completion: ([DynamicResult<K>]) -> Void) in
        completion([])
    }
    var resultByKey = { (_: K, completion: (DynamicResult<K>?) -> Void) in
        completion(nil)
    }

    init(parentViewController: UIViewController, label: String, inputPlaceholder: String = "", canClean: Bool = true, showLabel: Bool = true) {
        self.label = label
        self.canClean = canClean
        self.titleLabel.text = label
        self.parentViewController = parentViewController
        self.textField.placeholder = inputPlaceholder
        self.showLabel = showLabel
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        textField.addTarget(self, action: #selector(self.startSearching(_:)), for: .editingDidBegin)

        addSubviews()
        setupLayout()
    }

    func setup() {
        subscription = self.path.sink(receiveValue: { newValue in
            guard let newValue = newValue else {
                garanteeMainThread {
                    self.textField.text = nil
                }
                return
            }
            guard self.selectedTag?.value != newValue else { return }
            self.resultByKey(newValue) { result in
                guard let result = result else { return }
                garanteeMainThread {
                    self.select(label: result.value, value: result.key)
                }
            }
        })
    }

    @objc private func startSearching(_ textField: UITextField) {
        dynamicSearch = DynamicSearchViewController(inputText: textField, canClean: canClean)
        dynamicSearch!.selected = (selectedTag?.value).map { Set([$0]) } ?? Set()
        dynamicSearch!.onSelect = { selectedResult in
            if let selectedResult = selectedResult {
                self.select(label: selectedResult.value, value: selectedResult.key)
            } else {
                self.path.send(nil)
            }
        }
        dynamicSearch!.onChangeQuery = onChangeQuery
        parentViewController.present(dynamicSearch!, animated: true)
    }

    private func addSubviews() {
        if showLabel {
            addSubview(titleLabel)
        }
        addSubview(textField)
        textField.addChevron()
    }

    private func setupLayout() {
        let textFieldHeight: CGFloat = 40
        let titleLabelHeight: CGFloat = 15
        let padding: CGFloat = 10
        textField.height(textFieldHeight)

        if showLabel {
            titleLabel.height(titleLabelHeight)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: topAnchor),

                textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding)
            ])
        } else {
            textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomAnchor.constraint(equalTo: textField.bottomAnchor)
        ])
    }

    func select(label: String, value: K) {
        let newSelection = (label: label, value: value)
        textField.text = label
        if let selectedTag = selectedTag,
           selectedTag.value != newSelection.value {
            self.selectedTag = newSelection
        } else {
            self.selectedTag = newSelection
        }
        self.path.send(value)
    }
}

extension SelectComponent {
    func getHeight() -> CGFloat {
        textField.bounds.height +
        (showLabel ? titleLabel.bounds.height : 0) +
        10
    }

    func isFilled() -> Bool {
        path.value != nil
    }

    func clear() {
        textField.text = nil
        selectedTag = nil
        path.send(nil)
    }

    func getUserInput() -> String? { "" }

    func getTitle() -> String {
        return label
    }

    func setSubject(_ subject: CurrentValueSubject<Value, Never>) {
        self.path = subject
    }

    func getSubject() -> CurrentValueSubject<Value, Never>? {
        self.path
    }
}
