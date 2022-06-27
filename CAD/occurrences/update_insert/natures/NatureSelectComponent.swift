//
//  NatureSelectComponent.swift
//  CAD
//
//  Created by Samir Chaves on 14/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import Combine
import AgenteDeCampoCommon

class NatureSelectComponent: UIView {
    internal var type: FormFieldType = .select
    private var dynamicSearch: NatureSearchViewController?
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
    fileprivate var selectedTag: SelectedTag<UUID>?
    private(set) var path = CurrentValueSubject<(UUID, Bool)?, Never>(nil)
    fileprivate let label: String

    public var belongingNatures = Set<UUID>()

    // Events closures
    var onChangeQuery = { (_: String, completion: ([DynamicResult<UUID>]) -> Void) in
        completion([])
    }
    var resultByKey = { (_: UUID, completion: (DynamicResult<UUID>?) -> Void) in
        completion(nil)
    }

    init(parentViewController: UIViewController, label: String, inputPlaceholder: String, showLabel: Bool = true) {
        self.label = label
        self.titleLabel.text = label
        self.parentViewController = parentViewController
        self.textField.placeholder = inputPlaceholder
        self.showLabel = showLabel
        super.init(frame: .zero)

        subscription = self.path.sink(receiveValue: { newValue in
            guard let newValue = newValue?.0,
                  self.selectedTag?.value != newValue else { return }
            self.resultByKey(newValue) { result in
                guard let result = result else { return }
                garanteeMainThread {
                    self.select(label: result.value, value: result.key, isNewNature: false)
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
        dynamicSearch = NatureSearchViewController(inputText: textField)
        dynamicSearch!.selected = (selectedTag?.value).map { Set([$0]) } ?? Set()
        dynamicSearch!.belongingNatures = belongingNatures
        dynamicSearch!.onSelect = { selectedResult, isNewNature in
            if let selectedResult = selectedResult {
                self.select(label: selectedResult.value, value: selectedResult.key, isNewNature: isNewNature)
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

    func select(label: String, value: UUID, isNewNature: Bool) {
        let newSelection = (label: label, value: value)
        textField.text = label
        if let selectedTag = selectedTag,
           selectedTag.value != newSelection.value {
            self.selectedTag = newSelection
        } else {
            self.selectedTag = newSelection
        }
        self.path.send((value, isNewNature))
    }

    func clear() {
        textField.text = nil
        selectedTag = nil
        path.send(nil)
    }
}

