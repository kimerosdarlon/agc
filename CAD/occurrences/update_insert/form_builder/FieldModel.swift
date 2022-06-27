//
//  FieldModel.swift
//  CAD
//
//  Created by Samir Chaves on 29/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

enum FieldConflictMergeStrategy {
    case ours, theirs
}

struct FieldConflict {
    let version: Int
    let conflictingValue: String?
    var mergeStrategy: FieldConflictMergeStrategy?
}

struct FieldModel<K: Hashable>: Hashable {
    let key: K
    let field: GenericFormField
    var conflict: FieldConflict?

    init(key: K, field: GenericFormField) {
        self.key = key
        self.field = field
    }

    private init(key: K, field: GenericFormField, conflict: FieldConflict?) {
        self.init(key: key, field: field)
        self.conflict = conflict
    }

    static func == (lhs: FieldModel<K>, rhs: FieldModel<K>) -> Bool {
        lhs.key == rhs.key
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    func conflicting(with conflictingValue: String?, version: Int) -> Self {
        let conflict = FieldConflict(version: version, conflictingValue: conflictingValue)
        let fieldModel = FieldModel(key: key, field: field, conflict: conflict)
        return fieldModel
    }

    func resolveConflict(keeping: FieldConflictMergeStrategy) -> Self {
        let resolvedConflict = self.conflict.map { conflict in
            FieldConflict(version: conflict.version, conflictingValue: conflict.conflictingValue, mergeStrategy: keeping)
        }
        let fieldModel = FieldModel(key: key, field: field, conflict: resolvedConflict)
        return fieldModel
    }

    func noConflict() -> Self {
        let fieldModel = FieldModel(key: key, field: field, conflict: nil)
        return fieldModel
    }
}
