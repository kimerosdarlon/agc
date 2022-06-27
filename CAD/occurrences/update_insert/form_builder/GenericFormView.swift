//
//  GenericFormView.swift
//  CAD
//
//  Created by Samir Chaves on 28/10/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class GenericFormView<K: Hashable>: UIStackView, UITableViewDelegate {
    private var fields: [FieldModel<K>]
    private var hiddenFieldsKey = Set<K>()
    private var nonHiddenFields: [FieldModel<K>] {
        self.fields.filter { !self.hiddenFieldsKey.contains($0.key) }
    }

    enum Section { case main }
    private var fieldsViews = [GenericFieldView<K>]()

    init(fields: [FieldModel<K>]) {
        self.fields = fields
        self.fieldsViews = fields.map { GenericFieldView(fieldModel: $0) }
        super.init(frame: .zero)

        axis = .vertical
        distribution = .fill
        spacing = 0
        alignment = .fill
        contentMode = .scaleToFill
        semanticContentAttribute = .unspecified
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = .appBackground
        layoutMargins = .zero
        isExclusiveTouch = false

        addArrangedSubviewList(views: self.fieldsViews)
        self.fieldsViews.forEach { fieldView in
            fieldView.onChangeMergeStrategy = { strategy in
                self.fields = self.fields.map { field in
                    if field.key == fieldView.fieldModel.key {
                        return field.resolveConflict(keeping: strategy)
                    }

                    return field
                }
            }
        }
    }

    func setConflict(inFields fieldsConflicts: [K: String?], version: Int) {
        fields = fields.map { field in
            if let conflictingValue = fieldsConflicts[field.key] {
                return field.conflicting(with: conflictingValue, version: version)
            }

            return field.noConflict()
        }

        zip(fields, fieldsViews)
            .filter { $0.0.conflict != nil }
            .forEach { field, fieldView in
                fieldView.updateField(field)
            }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    func getConflictsMerging() -> [K: FieldConflictMergeStrategy?] {
        var mergingResults = [K: FieldConflictMergeStrategy?]()
        fieldsViews
            .filter { $0.fieldModel.conflict != nil }
            .forEach { field in
                mergingResults[field.fieldModel.key] = field.mergeStrategy
            }
        return mergingResults
    }

    func hideField(forKey key: K) {
        guard let field = fieldsViews.first(where: { $0.fieldModel.key == key }) else { return }
        UIView.animate(withDuration: 0.3) {
            field.isHidden = true
        }
    }

    func showField(forKey key: K) {
        guard let field = fieldsViews.first(where: { $0.fieldModel.key == key }) else { return }
        UIView.animate(withDuration: 0.3) {
            field.isHidden = false
        }
    }

    func isFieldHidden(ofKey key: K) -> Bool {
        guard let field = fieldsViews.first(where: { $0.fieldModel.key == key }) else { return false }
        return field.isHidden
    }
}
