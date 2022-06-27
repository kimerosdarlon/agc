//
//  MultiselectorComponent.swift
//  CAD
//
//  Created by Samir Chaves on 24/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import UIKit
import Combine

class MultiselectorComponent<K: Hashable>: UIView, FormField {
    typealias Value = [K]

    private var dynamicSearch: DynamicSearchViewController<K>?
    private let multiselectorTags = MultiselectorTagsCollectionView<K>(tags: []).enableAutoLayout()
    private var subscription: AnyCancellable?

    private let titleLabel = UILabel.build(withSize: 14, weight: .medium)
    private let textField: UITextField = {
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
    private var selectedTags = [SelectedTag<K>]()
    internal var type: FormFieldType = .multiselect
    private var path = CurrentValueSubject<[K], Never>([])
    private let label: String
    private let showLabel: Bool

    // Events closures
    var onChangeQuery = { (_: String, completion: ([DynamicResult<K>]) -> Void) in
        completion([])
    }
    var resultByKey = { (_: K, completion: (DynamicResult<K>?) -> Void) in
        completion(nil)
    }

    var onRemoveASelection = { (_: SelectedTag<K>, completion: @escaping (Bool) -> Void) in
        completion(true)
    }

    var onSelect = { (_: SelectedTag<K>, completion: @escaping (Bool) -> Void) in
        completion(true)
    }

    init(parentViewController: UIViewController, label: String, inputPlaceholder: String, showLabel: Bool = true) {
        self.label = label
        self.titleLabel.text = label
        self.parentViewController = parentViewController
        self.textField.placeholder = inputPlaceholder
        self.showLabel = showLabel
        super.init(frame: .zero)

        multiselectorTags.onRemoveASelection = { selection, completion in
            self.onRemoveASelection(selection) { shouldRemove in
                if shouldRemove {
                    self.selectedTags = self.selectedTags.filter { $0.value != selection.value }
                    let selectedTags = self.path.value.filter { $0 != selection.value }
                    self.path.send(selectedTags)
                }
                completion(shouldRemove)
            }
        }

        subscription = self.path.sink(receiveValue: { newValue in
            guard self.selectedTags.count != newValue.count else { return }
            newValue.forEach { key in
                self.resultByKey(key) { result in
                    guard let result = result else { return }
                    garanteeMainThread {
                        self.select(label: result.value, value: result.key)
                    }
                }
            }
        })
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

    @objc private func startSearching(_ textField: UITextField) {
        dynamicSearch = DynamicSearchViewController(inputText: textField)
        dynamicSearch!.selected = Set(selectedTags.map { $0.value })
        dynamicSearch!.onSelect = { selectedResult in
            if let selectedResult = selectedResult {
                let selectedTag = (label: selectedResult.value, value: selectedResult.key)
                self.onSelect(selectedTag) { shouldAdd in
                    if shouldAdd {
                        self.select(label: selectedResult.value, value: selectedResult.key)
                    }
                }
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
        addSubview(multiselectorTags)
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
            textField.topAnchor.constraint(equalTo: topAnchor, constant: padding).isActive = true
        }

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),

            multiselectorTags.leadingAnchor.constraint(equalTo: leadingAnchor),
            multiselectorTags.trailingAnchor.constraint(equalTo: trailingAnchor),
            multiselectorTags.topAnchor.constraint(equalTo: topAnchor, constant: textFieldHeight + titleLabelHeight + 1.5 * padding),
            bottomAnchor.constraint(equalTo: multiselectorTags.bottomAnchor, constant: -padding / 2)
        ])
    }

    func select(label: String, value: K) {
        let newSelection = (label: label, value: value)
        textField.text = nil
        if !selectedTags.contains(where: { $0.value == newSelection.value }) {
            selectedTags.insert(newSelection, at: 0)
            multiselectorTags.update(with: selectedTags) {
                self.path.send(self.selectedTags.map { $0.value })
            }
        }
    }
}

extension MultiselectorComponent {
    func getHeight() -> CGFloat {
        multiselectorTags.bounds.height +
        textField.bounds.height +
        (showLabel ? titleLabel.bounds.height : 0) +
        10
    }

    func isFilled() -> Bool {
        !path.value.isEmpty
    }

    func clear() {
        multiselectorTags.update(with: [])
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
