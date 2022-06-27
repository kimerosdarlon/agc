//
//  WeaponForm.swift
//  CAD
//
//  Created by Samir Chaves on 22/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class WeaponForm: UIView {
    let dataSource = WeaponDataSource()

    var typeField: SelectComponent<String>!
    var specieField: SelectComponent<String>!
    var brandField: SelectComponent<String>!
    var modelField: SelectComponent<String>!
    var manufactureField: SelectComponent<String>!
    var caliberField: SelectComponent<String>!
    var serialNumberField = OptionalTextFieldComponent(placeholder: "",
                                                       label: "Nº de Série",
                                                       checkboxLabel: "Raspado",
                                                       defaultText: "RASPADO",
                                                       showLabel: false)
    var sinarmNumberField = OptionalTextFieldComponent(placeholder: "",
                                                       label: "Nº Sinarm",
                                                       checkboxLabel: "Não informado",
                                                       defaultText: "NÃO INFORMADO",
                                                       showLabel: false)
    var bondWithInvolvedField: SelectComponent<String>!
    var destinationField: SelectComponent<String>!
    var notesField = TextAreaFieldComponent(label: "Observações", showLabel: false)

    internal var formBuilder: GenericForm<WeaponUpdate>!
    internal var formView: GenericForm<WeaponUpdate>.FormView!

    init(weaponUpdate: WeaponUpdate, parentViewController: UIViewController) {
        typeField = SelectComponent<String>(parentViewController: parentViewController,
                                            label: "Tipo de arma",
                                            showLabel: false)
        specieField = SelectComponent<String>(parentViewController: parentViewController,
                                              label: "Espécie",
                                              showLabel: false)
        brandField = SelectComponent<String>(parentViewController: parentViewController,
                                             label: "Marca",
                                             showLabel: false)
        modelField = SelectComponent<String>(parentViewController: parentViewController,
                                             label: "Modelo",                   
                                             showLabel: false)
        manufactureField = SelectComponent<String>(parentViewController: parentViewController,
                                                   label: "Fabricante",
                                                   showLabel: false)
        caliberField = SelectComponent<String>(parentViewController: parentViewController,
                                               label: "Calibre",
                                               showLabel: false)
        bondWithInvolvedField = SelectComponent<String>(parentViewController: parentViewController,
                                                        label: "Vínculo com o Envolvido",
                                                        showLabel: false)
        destinationField = SelectComponent<String>(parentViewController: parentViewController,
                                                   label: "Destino",
                                                   showLabel: false)

        super.init(frame: .zero)

        formBuilder = GenericForm(model: weaponUpdate)
            .addField(typeField, forKeyPath: \.type)
            .addField(specieField, forKeyPath: \.specie)
            .addField(brandField, forKeyPath: \.brand)
            .addField(modelField, forKeyPath: \.model)
            .addField(caliberField, forKeyPath: \.caliber)
            .addField(serialNumberField, forKeyPath: \.serialNumber)
            .addField(sinarmNumberField, forKeyPath: \.sinarmSigmaNumber)
            .addField(destinationField, forKeyPath: \.destination)
            .addField(manufactureField, forKeyPath: \.manufacture)
            .addField(bondWithInvolvedField, forKeyPath: \.bondWithInvolved)
            .addField(notesField, forKeyPath: \.note)
            .buildFormView()

        formView = formBuilder.formView

        dataSource.fetchData { error in
            garanteeMainThread {
                if let error = error as NSError? {
                    Toast.present(in: parentViewController, message: error.domain)
                } else {
                    self.setupTypeField()
                    self.setupSpecieField()
                    self.setupBrandField()
                    self.setupModelField()
                    self.setupManufactureField()
                    self.setupCaliberField()
                    self.setupBondWithInvolvedField()
                    self.setupDestinationField()
                }
            }
        }

        dataSource.selectedType = weaponUpdate.type

        formBuilder.listenForChanges(in: \.type) { newValue in
            self.dataSource.selectedType = newValue

            guard let newValue = newValue else {
                self.formView.hideField(forKey: \WeaponUpdate.specie)
                return
            }

            self.formView.showField(forKey: \WeaponUpdate.specie)
            self.formBuilder.send(value: nil, toField: \.specie)

            if newValue == "Arma de fogo longa" || newValue == "Arma de fogo curta" {
                self.showFieldsForGun()
            } else {
                self.hideFieldsForGun()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showFieldsForGun() {
        self.formView.showField(forKey: \WeaponUpdate.manufacture)
        self.formView.showField(forKey: \WeaponUpdate.brand)
        self.formView.showField(forKey: \WeaponUpdate.model)
        self.formView.showField(forKey: \WeaponUpdate.serialNumber)
        self.formView.showField(forKey: \WeaponUpdate.sinarmSigmaNumber)
        self.formView.showField(forKey: \WeaponUpdate.caliber)
    }

    func hideFieldsForGun() {
        self.formView.hideField(forKey: \WeaponUpdate.manufacture)
        self.formView.hideField(forKey: \WeaponUpdate.brand)
        self.formView.hideField(forKey: \WeaponUpdate.model)
        self.formView.hideField(forKey: \WeaponUpdate.serialNumber)
        self.formView.hideField(forKey: \WeaponUpdate.sinarmSigmaNumber)
        self.formView.hideField(forKey: \WeaponUpdate.caliber)
    }

    internal func searchMatch(query: NSRegularExpression, with term: String) -> NSRange? {
        let foldedTerm = term.prepareForSearch()
        let range = NSRange(location: 0, length: foldedTerm.utf16.count)
        return query.firstMatch(in: foldedTerm, options: [], range: range)?.range
    }

    func setupTypeField() {
        typeField?.onChangeQuery = { query, completion in
            guard let typesData = self.dataSource.domainData?.types else { return }
            guard !query.isEmpty else {
                let results = typesData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = typesData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        typeField?.resultByKey = { key, completion in
            guard let typesData = self.dataSource.domainData?.types else { return }
            let result = typesData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        typeField?.setup()
    }

    private func getSpeciesData() -> [DomainValue] {
        guard let speciesData = self.dataSource.domainData?.species.filter({ (specie) -> Bool in
            guard let selectedType = self.dataSource.selectedType,
                  let specieGroup = specie.group else { return false }
            return specieGroup.contains(selectedType)
        }) else { return [] }
        return speciesData
    }

    func setupSpecieField() {
        specieField?.onChangeQuery = { query, completion in
            let speciesData = self.getSpeciesData()
            guard !query.isEmpty else {
                let results = speciesData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = speciesData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        specieField?.resultByKey = { key, completion in
            let speciesData = self.getSpeciesData()
            let result = speciesData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        specieField?.setup()
    }

    func setupBrandField() {
        brandField?.onChangeQuery = { query, completion in
            guard let brandsData = self.dataSource.domainData?.brands else { return }
            guard !query.isEmpty else {
                let results = brandsData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = brandsData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        brandField?.resultByKey = { key, completion in
            guard let brandsData = self.dataSource.domainData?.brands else { return }
            let result = brandsData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        brandField?.setup()
    }

    func setupModelField() {
        modelField?.onChangeQuery = { query, completion in
            guard let modelsData = self.dataSource.domainData?.models else { return }
            guard !query.isEmpty else {
                let results = modelsData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = modelsData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        modelField?.resultByKey = { key, completion in
            guard let modelsData = self.dataSource.domainData?.models else { return }
            let result = modelsData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        modelField?.setup()
    }

    func setupManufactureField() {
        manufactureField?.onChangeQuery = { query, completion in
            guard let manufacturesData = self.dataSource.domainData?.manufactures else { return }
            guard !query.isEmpty else {
                let results = manufacturesData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = manufacturesData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        manufactureField?.resultByKey = { key, completion in
            guard let manufacturesData = self.dataSource.domainData?.manufactures else { return }
            let result = manufacturesData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        manufactureField?.setup()
    }

    func setupCaliberField() {
        caliberField?.onChangeQuery = { query, completion in
            let calibers = self.dataSource.domainData?.calibers
            guard let calibersDataNonUnique = calibers  else { return }
            let calibersData = Array(Set(calibersDataNonUnique))
            guard !query.isEmpty else {
                let results = calibersData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = calibersData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        caliberField?.resultByKey = { key, completion in
            let calibers = self.dataSource.domainData?.calibers
            guard let calibersDataNonUnique = calibers  else { return }
            let calibersData = Array(Set(calibersDataNonUnique))
            let result = calibersData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }
        caliberField?.setup()
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
}
