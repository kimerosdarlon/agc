//
//  FormBuilder.swift
//  CAD
//
//  Created by Samir Chaves on 28/10/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import UIKit
import Combine

class GenericForm<M> {
    typealias FormView = GenericFormView<PartialKeyPath<M>>

    private(set) var model: M
    private var previousModel: M
    private var remoteModel: M?
    private let readSubject: PassthroughSubject<M, Never>
    private let writeSubject: PassthroughSubject<M, Never>
    private var fieldModels = [FieldModel<PartialKeyPath<M>>]()
    private var fields = [GenericFormField]()
    private var subscriptions = Set<AnyCancellable>()
    private var fieldsResolvedAsTheirs = [PartialKeyPath<M>]()
    private(set) var formView: GenericFormView<PartialKeyPath<M>>?
    private(set) var isMerging: Bool = false

    init(model: M) {
        self.model = model
        self.previousModel = model
        self.readSubject = .init()
        self.writeSubject = .init()
    }

    private func internalFieldInsertion<T, F: FormField>(
        _ field: F,
        forKeyPath keyPath: WritableKeyPath<M, T>,
        requireViewUpdate: Bool = false,
        fieldModel: FieldModel<PartialKeyPath<M>>
    ) where F.Value == T {
        fieldModels.append(fieldModel)
        fields.append(field)

        let fieldSubject = field.getSubject()
        fieldSubject?.send(self.model[keyPath: keyPath])
        fieldSubject?.sink(receiveValue: { newValue in
            self.previousModel = self.model
            self.model[keyPath: keyPath] = newValue
            self.readSubject.send(self.model)

//            if let fieldModel = self.fieldModels.first(where: { $0.key == keyPath }),
//               let conflict = fieldModel.conflict,
//               let mergeStrategy = conflict.mergeStrategy,
//               let remoteModel = self.remoteModel,
//               mergeStrategy == .theirs, self.isMerging {
//                self.model[keyPath: keyPath] = remoteModel[keyPath: keyPath]
//            }
        })
        .store(in: &subscriptions)

        writeSubject
            .map(keyPath)
            .sink(receiveValue: { newValue in
                fieldSubject?.send(newValue)
            })
            .store(in: &subscriptions)
    }

    func extractWritableKey<T>(keyPath: WritableKeyPath<M, T>) -> WritableKeyPath<M, T> {
        return keyPath
    }

    func addField<T, F: FormField>(
        _ field: F,
        forKeyPath keyPath: WritableKeyPath<M, T>,
        requireViewUpdate: Bool = false
    ) -> Self where F.Value == T {
        let fieldModel = FieldModel(key: keyPath as PartialKeyPath<M>, field: field)
        self.internalFieldInsertion(field, forKeyPath: keyPath, requireViewUpdate: requireViewUpdate, fieldModel: fieldModel)
        return self
    }

    func listenForChanges<T: Equatable>(in keyPath: KeyPath<M, T>, listener: @escaping (T) -> Void) {
        readSubject
            .map(keyPath)
            .filter { $0 != self.previousModel[keyPath: keyPath] }
            .sink(receiveValue: listener)
            .store(in: &subscriptions)
    }

    func listenForChanges(listener: @escaping () -> Void) {
        readSubject
            .sink(receiveValue: { _ in listener() })
            .store(in: &subscriptions)
    }

    func buildFormView() -> Self {
        formView = GenericFormView(fields: fieldModels)
        return self
    }

    func setConflictsTo(fieldsKeys: [PartialKeyPath<M>: String?], version: Int) {
        if !fieldsKeys.isEmpty {
            isMerging = true
//            self.remoteModel = remoteModel
            self.formView?.setConflict(inFields: fieldsKeys, version: version)
        }
    }

    func getConflictsMerging() -> [PartialKeyPath<M>: FieldConflictMergeStrategy?] {
        formView?.getConflictsMerging() ?? [:]
    }

    func send<T>(value: T, toField fieldKeyPath: WritableKeyPath<M, T>) {
        self.previousModel = self.model
        model[keyPath: fieldKeyPath] = value
        writeSubject.send(model)
    }
}
