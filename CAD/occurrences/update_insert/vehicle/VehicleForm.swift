//
//  VehicleForm.swift
//  CAD
//
//  Created by Samir Chaves on 14/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import Vehicle

class VehicleForm: UIView {
    let dataSource = VehicleDataSource()

    let plateField = TextFieldComponent(placeholder: "AAA-0000", label: "Placa", type: .plate, showLabel: false)
    let brandField = TextFieldComponent(placeholder: "ex.: Fiat", label: "Marca", showLabel: false)
    let typeField = TextFieldComponent(placeholder: "", label: "Tipo", showLabel: false)
    let modelField = TextFieldComponent(placeholder: "ex.: Palio", label: "Modelo", showLabel: false)
    let chassisField = TextFieldComponent(placeholder: "", label: "Chassi", showLabel: false)
    let colorField = TextFieldComponent(placeholder: "Ex.: Azul", label: "Cor", showLabel: false)
    let characteristicsField = TextFieldComponent(placeholder: "", label: "Características", showLabel: false)
    var escapedField: SelectComponent<String>!
    var moveConditionField: SelectComponent<String>!
    var bondWithInvolvedField: SelectComponent<String>!
    let restrictionField = TextFieldComponent(placeholder: "", label: "Restrição", showLabel: false)
    let robberyTheftField = CheckboxFieldComponent(label: "Roubo ou furto", fieldName: "")
    var notesField = TextAreaFieldComponent(label: "Observações", showLabel: false)

    internal var formBuilder: GenericForm<VehicleUpdate>!
    internal var formView: GenericForm<VehicleUpdate>.FormView!

    private let vehicleService = VehicleService()

    init(vehicleUpdate: VehicleUpdate, parentViewController: UIViewController) {
        super.init(frame: .zero)
        robberyTheftField.valueWhenChecked = "Sim"
        robberyTheftField.valueWhenUnchecked = "Não"
        
        escapedField = SelectComponent<String>(parentViewController: parentViewController,
                                               label: "Escapou",
                                               showLabel: false)
        moveConditionField = SelectComponent<String>(parentViewController: parentViewController,
                                                     label: "Condições de deslocamento",
                                                     showLabel: false)
        bondWithInvolvedField = SelectComponent<String>(parentViewController: parentViewController,
                                                        label: "Vínculo com o Envolvido",
                                                        showLabel: false)

        formBuilder = GenericForm(model: vehicleUpdate)
            .addField(plateField, forKeyPath: \.plate)
            .addField(robberyTheftField, forKeyPath: \.robberyTheft)
            .addField(brandField, forKeyPath: \.brand)
            .addField(modelField, forKeyPath: \.model)
            .addField(typeField, forKeyPath: \.type)
            .addField(chassisField, forKeyPath: \.chassis)
            .addField(colorField, forKeyPath: \.color)
            .addField(characteristicsField, forKeyPath: \.characteristics)
            .addField(escapedField, forKeyPath: \.escaped)
            .addField(moveConditionField, forKeyPath: \.moveCondition)
            .addField(bondWithInvolvedField, forKeyPath: \.bondWithInvolved)
            .addField(restrictionField, forKeyPath: \.restriction)
            .addField(notesField, forKeyPath: \.note)
            .buildFormView()

        formView = formBuilder.formView

        dataSource.fetchData { error in
            if error == nil {
                garanteeMainThread {
                    self.setupEscapedField()
                    self.setupMoveConditionField()
                    self.setupBondWithInvolvedField()
                }
            }
        }

        formBuilder.listenForChanges(in: \.plate) { newValue in
            guard let plate = newValue else { return }
            if plate.matches(inAny: AppRegex.platePatterns) {
                self.vehicleService.findBy(search: plate) { result in
                    garanteeMainThread {
                        switch result {
                        case .success(let vehicleResult):
                            guard let vehicle = vehicleResult.first?.toVehicle() else { return }
                            let brandAndModel = vehicle.model?.split(separator: "/")
                            let brand = brandAndModel?.first.map { String($0) }
                            let model = brandAndModel?.last.map { String($0) }
                            self.formBuilder.send(value: vehicle.color, toField: \.color)
                            self.formBuilder.send(value: model, toField: \.model)
                            self.formBuilder.send(value: brand, toField: \.brand)
                            self.formBuilder.send(value: vehicle.chassis, toField: \.chassis)
                            self.formBuilder.send(value: vehicle.type, toField: \.type)
                            self.formBuilder.send(value: vehicle.restrictions?.joined(separator: ", "), toField: \.restriction)
                            self.formBuilder.send(value: vehicle.hasAlert ? "Sim" : "Não", toField: \.robberyTheft)
                        case .failure(let error as NSError):
                            Toast.present(in: parentViewController, message: error.domain)
                        }
                    }
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

    func setupEscapedField() {
        escapedField?.onChangeQuery = { query, completion in
            guard let escapedData = self.dataSource.domainData?.escaped else { return }
            guard !query.isEmpty else {
                let results = escapedData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = escapedData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        escapedField?.resultByKey = { key, completion in
            guard let escapedData = self.dataSource.domainData?.escaped else { return }
            let result = escapedData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }

        escapedField?.setup()
    }

    func setupMoveConditionField() {
        moveConditionField?.onChangeQuery = { query, completion in
            guard let moveConditionData = self.dataSource.domainData?.moveCondition else { return }
            guard !query.isEmpty else {
                let results = moveConditionData.map { DynamicResult(key: $0.option, value: $0.label) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = moveConditionData.filter { item in
                self.searchMatch(query: queryRegex, with: item.label) != nil
            }.map { DynamicResult(key: $0.option, value: $0.label) }

            completion(results)
        }

        moveConditionField?.resultByKey = { key, completion in
            guard let moveConditionData = self.dataSource.domainData?.moveCondition else { return }
            let result = moveConditionData.first(where: { $0.option == key }).map {
                DynamicResult(key: $0.option, value: $0.label)
            }
            completion(result)
        }

        moveConditionField?.setup()
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
