//
//  GenericFieldView.swift
//  CAD
//
//  Created by Samir Chaves on 07/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class GenericFieldView<K: Hashable>: UIView {

    private(set) var fieldModel: FieldModel<K>

    private let titleLabel = UILabel.build(withSize: 13, weight: .bold, color: .appTitle)
    private let readOnlyField = ROGenericField<String>(transform: { a in a }).enableAutoLayout()
    private let conflictingCheckbox = Checkbox(style: .squared).enableAutoLayout()
    private let conflictingCheckboxContainer = UIView(frame: .zero).enableAutoLayout()
    private let editableCheckbox = Checkbox(style: .squared).enableAutoLayout()
    private let editableCheckboxContainer = UIView(frame: .zero).enableAutoLayout()
    private var editableFieldContainer = UIView().enableAutoLayout()
    private var editableField: UIView?
    private var hasConflict = false
    private var estimatedTextHeight: CGFloat = 0
    private var readOnlyFieldHeightConstraint: NSLayoutConstraint?
    private var readOnlyFieldMarginConstraint: NSLayoutConstraint?
    private var editableCheckboxConstraint: NSLayoutConstraint?
    private(set) var mergeStrategy: FieldConflictMergeStrategy?

    var onChangeMergeStrategy: (FieldConflictMergeStrategy) -> Void = { _ in }

    @objc private func didTapOnConflictingField() {
        conflictingCheckbox.isChecked = true
        editableCheckbox.isChecked = false
        readOnlyField.alpha = 1
        editableField?.alpha = 0.6
        mergeStrategy = .theirs
        onChangeMergeStrategy(mergeStrategy!)
    }

    @objc private func didTapOnEditableField() {
        conflictingCheckbox.isChecked = false
        editableCheckbox.isChecked = true
        readOnlyField.alpha = 0.6
        editableField?.alpha = 1
        mergeStrategy = .ours
        onChangeMergeStrategy(mergeStrategy!)
    }

    init(fieldModel: FieldModel<K>) {
        self.fieldModel = fieldModel
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        backgroundColor = .clear
        isUserInteractionEnabled = false
        backgroundColor = .appBackground
        isUserInteractionEnabled = true

        addSubview(titleLabel)
        addSubview(readOnlyField)
        addSubview(conflictingCheckboxContainer)
        addSubview(editableCheckboxContainer)
        addSubview(editableFieldContainer)
        editableFieldContainer.addSubview(fieldModel.field)

        titleLabel.text = fieldModel.field.getTitle()
        editableField = fieldModel.field
        fieldModel.field.enableAutoLayout()

        editableFieldContainer.clipsToBounds = true

        conflictingCheckboxContainer.addSubview(conflictingCheckbox)
        conflictingCheckboxContainer.clipsToBounds = true
        editableCheckboxContainer.addSubview(editableCheckbox)
        editableCheckboxContainer.clipsToBounds = true

        let conflictingTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnConflictingField))
        conflictingCheckboxContainer.addGestureRecognizer(conflictingTapGesture)
        let editableTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnEditableField))
        editableCheckboxContainer.addGestureRecognizer(editableTapGesture)

        conflictingCheckboxContainer.width(60)
        editableCheckboxConstraint = editableCheckboxContainer.widthAnchor.constraint(equalToConstant: 0)
        editableCheckboxConstraint?.isActive = true

        readOnlyFieldHeightConstraint = readOnlyField.heightAnchor.constraint(equalToConstant: 0)
        readOnlyFieldHeightConstraint?.isActive = true
        readOnlyFieldMarginConstraint = readOnlyField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0)
        readOnlyFieldMarginConstraint?.isActive = true

        conflictingCheckbox
            .width(20).height(20)
            .centerY(view: conflictingCheckboxContainer)
            .centerX(view: conflictingCheckboxContainer)
        conflictingCheckbox.isChecked = false
        conflictingCheckbox.isUserInteractionEnabled = false
        editableCheckbox
            .width(20).height(20)
            .centerY(view: editableCheckboxContainer)
            .centerX(view: editableCheckboxContainer)
        editableCheckbox.isChecked = false
        editableCheckbox.isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),

            readOnlyField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            readOnlyField.trailingAnchor.constraint(equalTo: conflictingCheckboxContainer.leadingAnchor),

            editableFieldContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            editableFieldContainer.trailingAnchor.constraint(equalTo: editableCheckboxContainer.leadingAnchor),
            editableFieldContainer.topAnchor.constraint(equalTo: readOnlyField.bottomAnchor, constant: 10),
            editableFieldContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),

            conflictingCheckboxContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            conflictingCheckboxContainer.centerYAnchor.constraint(equalTo: readOnlyField.centerYAnchor),
            conflictingCheckboxContainer.topAnchor.constraint(equalTo: readOnlyField.topAnchor),
            conflictingCheckboxContainer.bottomAnchor.constraint(equalTo: readOnlyField.bottomAnchor),

            editableCheckboxContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            editableCheckboxContainer.centerYAnchor.constraint(equalTo: editableFieldContainer.centerYAnchor),
            editableCheckboxContainer.heightAnchor.constraint(equalTo: editableFieldContainer.heightAnchor),

            fieldModel.field.leadingAnchor.constraint(equalTo: editableFieldContainer.leadingAnchor),
            fieldModel.field.trailingAnchor.constraint(equalTo: editableFieldContainer.trailingAnchor),
            fieldModel.field.topAnchor.constraint(equalTo: editableFieldContainer.topAnchor),
            fieldModel.field.bottomAnchor.constraint(equalTo: editableFieldContainer.bottomAnchor)
        ])
    }

    func updateField(_ newField: FieldModel<K>) {
        fieldModel = newField
        if let conflict = newField.conflict {
            readOnlyField.path?.send(conflict.conflictingValue)
            readOnlyField.setVersion(conflict.version)
            estimatedTextHeight = conflict.conflictingValue?.height(
                withConstrainedWidth: bounds.width - 60, font: UIFont.systemFont(ofSize: 14)
            ) ?? 0
            estimatedTextHeight = estimatedTextHeight + 35

            self.editableCheckboxConstraint?.constant = 60
            self.readOnlyFieldHeightConstraint?.constant = self.estimatedTextHeight
            self.readOnlyFieldMarginConstraint?.constant = 10
        } else {
            self.editableCheckboxConstraint?.constant = 0
            self.readOnlyFieldHeightConstraint?.constant = 0
            self.readOnlyFieldMarginConstraint?.constant = 0
        }
    }
}
