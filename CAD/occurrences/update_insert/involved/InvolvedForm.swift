//
//  InvolvedForm.swift
//  CAD
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import Combine

class InvolvedForm: UIView {
    let dataSource = InvolvedDataSource()

    private let nameField = TextFieldComponent(placeholder: "", label: "Nome", showLabel: false)
    private let genderField: SelectComponent<String>!
    private let colorRaceField: SelectComponent<String>!
    private let motherNameField = TextFieldComponent(placeholder: "", label: "Nome da mãe", showLabel: false)
    private let birthdateField = DateFieldComponent(label: "Data de nascimento", showLabel: false)
    private let documentTypeField: SelectComponent<String>!
    private let documentNumberField = TextFieldComponent(placeholder: "", label: "Número do documento", showLabel: false)
    private let warrantNumberField = TextFieldComponent(placeholder: "", label: "Número do mandado", showLabel: false)
    private let organInitialsField = TextFieldComponent(placeholder: "", label: "Órgão responsável", showLabel: false)
    private let notesField = TextAreaFieldComponent(label: "Observações", showLabel: false)

    internal var formBuilder: GenericForm<InvolvedUpdate>!
    internal var formView: GenericForm<InvolvedUpdate>.FormView!

    init(involvedUpdate: InvolvedUpdate, parentViewController: UIViewController) {
        genderField = SelectComponent<String>(parentViewController: parentViewController,
                                              label: "Gênero",
                                              showLabel: false)
        colorRaceField = SelectComponent<String>(parentViewController: parentViewController,
                                                 label: "Raça",
                                                 showLabel: false)
        documentTypeField = SelectComponent<String>(parentViewController: parentViewController,
                                                    label: "Tipo de documento",
                                                    showLabel: false)
        super.init(frame: .zero)

        formBuilder = GenericForm(model: involvedUpdate)
            .addField(nameField, forKeyPath: \.name)
            .addField(genderField, forKeyPath: \.gender)
            .addField(colorRaceField, forKeyPath: \.colorRace)
            .addField(motherNameField, forKeyPath: \.motherName)
            .addField(birthdateField, forKeyPath: \.birthDate)
            .addField(documentTypeField, forKeyPath: \.documentType)
            .addField(documentNumberField, forKeyPath: \.documentNumber)
            .addField(warrantNumberField, forKeyPath: \.warrantNumber)
            .addField(organInitialsField, forKeyPath: \.organInitials)
            .addField(notesField, forKeyPath: \.note)
            .buildFormView()

        formView = formBuilder.formView

        dataSource.fetchData { error in
            if error == nil {
                garanteeMainThread {
                    self.setupGenderField()
                    self.setupColorRaceField()
                    self.setupDocumentTypeField()
                }
            }
        }

        formBuilder.listenForChanges(in: \.documentType) { documentType in
            guard let documentType = documentType else { return }
            if documentType == "CPF" {
                self.documentNumberField.textValidationType = .cpf
            } else {
                self.documentNumberField.textValidationType = .plain
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

    func setupGenderField() {
        genderField?.onChangeQuery = { query, completion in
            guard let gendersData = self.dataSource.domainData?.sexes else { return }
            guard !query.isEmpty else {
                let results = gendersData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = gendersData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        genderField?.resultByKey = { key, completion in
            guard let gendersData = self.dataSource.domainData?.sexes else { return }
            let result = gendersData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }

        genderField?.setup()
    }

    func setupColorRaceField() {
        colorRaceField?.onChangeQuery = { query, completion in
            guard let colorRacesData = self.dataSource.domainData?.races else { return }
            guard !query.isEmpty else {
                let results = colorRacesData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = colorRacesData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        colorRaceField?.resultByKey = { key, completion in
            guard let colorRacesData = self.dataSource.domainData?.races else { return }
            let result = colorRacesData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }

        colorRaceField?.setup()
    }

    func setupDocumentTypeField() {
        documentTypeField?.onChangeQuery = { query, completion in
            guard let documentTypesData = self.dataSource.domainData?.documentTypes else { return }
            guard !query.isEmpty else {
                let results = documentTypesData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = documentTypesData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        documentTypeField?.resultByKey = { key, completion in
            guard let documentTypesData = self.dataSource.domainData?.documentTypes else { return }
            let result = documentTypesData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }

        documentTypeField?.setup()
    }
}
