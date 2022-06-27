//
//  DrugForm.swift
//  CAD
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import Combine

class DrugForm: UIView {
    let dataSource = DrugDataSource()

    private let apparentTypeField: SelectComponent<String>!
    private let packageField: SelectComponent<String>!
    private let measureUnitField: SelectComponent<String>!
    private let quantityField = TextFieldComponent(placeholder: "", label: "Quantidade", keyboardType: .decimalPad, showLabel: false)
    private let bondWithInvolvedField: SelectComponent<String>!
    private let destinationField: SelectComponent<String>!
    private let notesField = TextAreaFieldComponent(label: "Observações", showLabel: false)

    internal var formBuilder: GenericForm<DrugUpdate>!
    internal var formView: GenericForm<DrugUpdate>.FormView!

    init(drugUpdate: DrugUpdate, parentViewController: UIViewController) {

        apparentTypeField = SelectComponent<String>(parentViewController: parentViewController,
                                                    label: "Tipo aparente",
                                                    showLabel: false)
        packageField = SelectComponent<String>(parentViewController: parentViewController,
                                               label: "Tipo de embalagem",
                                               showLabel: false)
        measureUnitField = SelectComponent<String>(parentViewController: parentViewController,
                                                   label: "Unidade de medida",
                                                   showLabel: false)
        destinationField = SelectComponent<String>(parentViewController: parentViewController,
                                                   label: "Destino",
                                                   showLabel: false)
        bondWithInvolvedField = SelectComponent<String>(parentViewController: parentViewController,
                                                        label: "Vínculo com o envolvido",
                                                        showLabel: false)

        super.init(frame: .zero)

        formBuilder = GenericForm(model: drugUpdate)
            .addField(apparentTypeField, forKeyPath: \.apparentType)
            .addField(packageField, forKeyPath: \.package)
            .addField(measureUnitField, forKeyPath: \.measureUnit)
            .addField(quantityField, forKeyPath: \.quantity)
            .addField(destinationField, forKeyPath: \.destination)
            .addField(bondWithInvolvedField, forKeyPath: \.bondWithInvolved)
            .addField(notesField, forKeyPath: \.note)
            .buildFormView()

        formView = formBuilder.formView

        dataSource.fetchData { error in
            if error == nil {
                garanteeMainThread {
                    self.setupApparentTypeField()
                    self.setupPackageField()
                    self.setupMeasureUnitField()
                    self.setupDestinationField()
                    self.setupBondWithInvolvedField()
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func searchMatch(query: NSRegularExpression, with term: String) -> NSRange? {
        let foldedTerm = term.prepareForSearch()
        let range = NSRange(location: 0, length: foldedTerm.utf16.count)
        return query.firstMatch(in: foldedTerm, options: [], range: range)?.range
    }

    func setupApparentTypeField() {
        apparentTypeField?.onChangeQuery = { query, completion in
            guard let apparentTypesData = self.dataSource.domainData?.apparentTypes else { return }
            guard !query.isEmpty else {
                let results = apparentTypesData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = apparentTypesData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        apparentTypeField?.resultByKey = { key, completion in
            guard let apparentTypesData = self.dataSource.domainData?.apparentTypes else { return }
            let result = apparentTypesData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        apparentTypeField?.setup()
    }

    func setupPackageField() {
        packageField?.onChangeQuery = { query, completion in
            guard let packagesData = self.dataSource.domainData?.packaging else { return }
            guard !query.isEmpty else {
                let results = packagesData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = packagesData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        packageField?.resultByKey = { key, completion in
            guard let packagesData = self.dataSource.domainData?.packaging else { return }
            let result = packagesData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        packageField?.setup()
    }

    func setupMeasureUnitField() {
        measureUnitField?.onChangeQuery = { query, completion in
            guard let measureUnitsData = self.dataSource.domainData?.unitiesOfMeasure else { return }
            guard !query.isEmpty else {
                let results = measureUnitsData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = measureUnitsData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        measureUnitField?.resultByKey = { key, completion in
            guard let measureUnitsData = self.dataSource.domainData?.unitiesOfMeasure else { return }
            let result = measureUnitsData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        measureUnitField?.setup()
    }

    func setupDestinationField() {
        destinationField?.onChangeQuery = { query, completion in
            guard let destinationsData = self.dataSource.domainData?.destinations else { return }
            guard !query.isEmpty else {
                let results = destinationsData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = destinationsData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        destinationField?.resultByKey = { key, completion in
            guard let destinationsData = self.dataSource.domainData?.destinations else { return }
            let result = destinationsData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        destinationField?.setup()
    }

    func setupBondWithInvolvedField() {
        bondWithInvolvedField?.onChangeQuery = { query, completion in
            guard let involvedLinksData = self.dataSource.domainData?.involvedLinks else { return }
            guard !query.isEmpty else {
                let results = involvedLinksData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = involvedLinksData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        bondWithInvolvedField?.resultByKey = { key, completion in
            guard let involvedLinksData = self.dataSource.domainData?.involvedLinks else { return }
            let result = involvedLinksData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        bondWithInvolvedField?.setup()
    }
}
