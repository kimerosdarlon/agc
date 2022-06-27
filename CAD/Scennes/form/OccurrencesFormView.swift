//
//  OccurrencesFormView.swift
//  CAD
//
//  Created by Samir Chaves on 05/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class OccurrencesFormView: UITableView, UITextFieldDelegate {

    internal let parentViewController: UIViewController
    internal var formSections = [FormSection]()

    var fields: [GenericFormField] {
        return formSections.flatMap { section in
            section.fields
        }
    }

    @PlacesServiceInject
    internal var placesService: PlacesService

    @CadServiceInject
    internal var cadService: CadService

    @domainServiceInject
    internal var domainService: DomainService

    @OccurrenceServiceInject
    internal var occurrenceService: OccurrenceService

    internal var naturesData = [Nature]()
    internal var placeTypesData = [PlaceType]()
    internal var statesData = [State]()
    internal var citiesData = [City]()
    internal var agenciesData = [Agency]()

    internal var selectedAgencyId: String? {
        didSet {
            if let selectedAgencyId = selectedAgencyId {
                populateNatures(agencyId: selectedAgencyId)
                populateOperatingRegions(agencyId: selectedAgencyId)
            }
        }
    }

    var viewModel: CadFilterViewModel
    let myOccurrencesField = CheckboxFieldComponent(label: "Consultar somente em minhas ocorrências", fieldName: "Pessoa")
    let agencyField = TextFieldComponent(placeholder: "Ex.: PMCE", label: "Busque e selecione a agência desejada:", fieldName: "Agência", keyboardType: .default, initialState: .loading, forSelect: true)
    let protocolField = TextFieldComponent(placeholder: "0000000000000000000", label: "Protocolo: ", keyboardType: .default)
    let situationsField = TagsFieldComponent<String>(title: "Situações: ", tags: [])
    let natureField = TextFieldComponent(placeholder: "Ex.: Ameaça de bombas", label: "Busque e selecione a natureza desejada: ", fieldName: "Natureza", keyboardType: .default, forSelect: true)
    let dateRangeStartField = DateTimeFieldComponent(label: "Data e hora inicial: ")
    let dateRangeEndField = DateTimeFieldComponent(label: "Data e hora final: ", initialHours: 23, initialMinutes: 59)
    let placeTypeField = TextFieldComponent(placeholder: "Ex.: Área rural", label: "Tipo de local: ", keyboardType: .default, forSelect: true)
    let streetField = TextFieldComponent(placeholder: "Ex.: Rua A", label: "Logradouro: ", keyboardType: .default)
    let stateField = TextFieldComponent(placeholder: "Ex.: Ceará - CE", label: "Estado UF: ", keyboardType: .default, forSelect: true)
    let cityField = TextFieldComponent(placeholder: "Ex.: Fortaleza", label: "Cidade: ", keyboardType: .default, forSelect: true)
    let districtField = TextFieldComponent(placeholder: "Ex.: Pici", label: "Bairro: ", keyboardType: .default)
    let referencePointField = TextFieldComponent(placeholder: "Ex.: Próximo ao Terminal Rodoviário", label: "Ponto de Referência: ", keyboardType: .default)
    let operatingRegionsField = TagsFieldComponent<String>(fieldName: "Regiões de Atuação", tags: [])
    let involvedNameField = TextFieldComponent(placeholder: "Ex: João da Silva", label: "Nome: ", keyboardType: .default)
    let involvedCpfField = TextFieldComponent(placeholder: "000.000.000-00", label: "CPF: ", keyboardType: .numberPad, type: .cpf)
    let involvedBirthdateField = DateFieldComponent(label: "Data de Nascimento: ")
    let involvedMotherNameField = TextFieldComponent(placeholder: "Nome da mãe", label: "Nome da mãe: ", keyboardType: .default)
    let vehiclePlateField = TextFieldComponent(placeholder: "AAA-0000 ou AAA-0A00", label: "Placa: ", keyboardType: .default, type: .plate)

    let naturesSection: FormSection
    let operatingRegionsSection: FormSection
    let locationSection: FormSection
    let cityFieldLine: FormLine

    init(viewModel: CadFilterViewModel, parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        self.viewModel = viewModel

        cityFieldLine = FormLine(cityField, isHidden: false)
        naturesSection = FormSection(title: "Natureza", lines: [
            FormLine(natureField)
        ], isExpanded: true, disabled: true, disabledMessage: "Selecione uma agência para visualizar as naturezas")
        operatingRegionsSection = FormSection(title: "Regiões de Atuação", lines: [
            FormLine(operatingRegionsField)
        ], isExpanded: true, disabled: true, disabledMessage: "Selecione uma agência para visualizar as regiões de atuação")
        locationSection = FormSection(title: "Localização", lines: [
            FormLine(placeTypeField),
            FormLine(streetField),
            FormLine(stateField),
            cityFieldLine,
            FormLine(districtField),
            FormLine(referencePointField)
        ], isExpanded: true)
        super.init(frame: .zero, style: .plain)

        self.viewModel.delegate = self

        natureField.textField.delegate = self
        formSections = [
            FormSection(title: "", lines: [
                FormLine(myOccurrencesField),
                FormLine(dateRangeStartField),
                FormLine(dateRangeEndField)
            ], isExpanded: true, isStatic: true),
            FormSection(title: "Agência", lines: [
                FormLine(agencyField)
            ], isExpanded: true),
            operatingRegionsSection,
            naturesSection,
            FormSection(title: "Dados Gerais", lines: [
                FormLine(protocolField),
                FormLine(situationsField)
            ], isExpanded: true),
            FormSection(title: "Veículo", lines: [
                FormLine(vehiclePlateField)
            ], isExpanded: true),
            locationSection,
            FormSection(title: "Envolvido", lines: [
                FormLine(involvedNameField),
                FormLine(involvedCpfField),
                FormLine(involvedBirthdateField),
                FormLine(involvedMotherNameField)
            ], isExpanded: true)
        ]

        register(FormFieldCell.self, forCellReuseIdentifier: FormFieldCell.identifier)
        delegate = self
        dataSource = self
        backgroundColor = .appBackground
        separatorStyle = .none
        estimatedRowHeight = 80
        rowHeight = UITableView.automaticDimension

        populateSituations()
        populatePlaceTypes()
        populateStates()
        populateAgencies()
        operatingRegionsField.setTags([])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func openSection(_ sectionIndex: Int) {
        for (i, section) in formSections.enumerated() where sectionIndex != i {
            section.isExpanded = false
        }
        reloadData()
    }

    override func didMoveToSuperview() {
        situationsField.onSelect = { (justSelected, allSelected) in
            if justSelected.key == "TODOS" {
                self.situationsField.selectTags([justSelected.key])
            } else if allSelected.firstIndex(where: { $0.key == "TODOS" }) != nil {
                let selectedKeys = allSelected.filter { $0.key != "TODOS" }.map { $0.key }
                self.situationsField.selectTags(Set(selectedKeys))
            }
        }

        agencyField.textField.addSearchIcon()
        agencyField.textField.addTarget(self, action: #selector(agenciesFieldBeginEditing), for: .editingDidBegin)

        placeTypeField.textField.addSearchIcon()
        placeTypeField.textField.addTarget(self, action: #selector(placeTypesFieldBeginEditing), for: .editingDidBegin)

        natureField.textField.addSearchIcon()
        natureField.textField.addTarget(self, action: #selector(naturesFieldBeginEditing), for: .editingDidBegin)

        stateField.textField.addSearchIcon()
        stateField.textField.addTarget(self, action: #selector(stateFieldBeginEditing), for: .editingDidBegin)

        cityField.textField.addSearchIcon()
        cityField.textField.addTarget(self, action: #selector(cityFieldBeginEditing), for: .editingDidBegin)

        let userProfile = cadService.getProfile()
        myOccurrencesField.labelWhenChecked = userProfile?.person.name
        myOccurrencesField.valueWhenChecked = userProfile?.person.id.uuidString
        
        myOccurrencesField.setSubject(viewModel.person)
        agencyField.setSubject(viewModel.agency)
        protocolField.setSubject(viewModel.`protocol`)
        situationsField.setSubject(viewModel.situations)
        dateRangeStartField.setSubject(viewModel.dateRangeStart)
        dateRangeEndField.setSubject(viewModel.dateRangeEnd)
        placeTypeField.setSubject(viewModel.placeType)
        natureField.setSubject(viewModel.nature)
        streetField.setSubject(viewModel.street)
        stateField.setSubject(viewModel.state)
        cityField.setSubject(viewModel.city)
        districtField.setSubject(viewModel.district)
        vehiclePlateField.setSubject(viewModel.vehiclePlate)
        referencePointField.setSubject(viewModel.referencePoint)
        operatingRegionsField.setSubject(viewModel.operatingRegions)
        involvedNameField.setSubject(viewModel.involvedName)
        involvedCpfField.setSubject(viewModel.involvedCpf)
        involvedBirthdateField.setSubject(viewModel.involvedBirthdate)
        involvedMotherNameField.setSubject(viewModel.involvedMotherName)

        protocolField.textField.text = viewModel.protocol.value
        if let dateStartString = viewModel.dateRangeStart.value,
           let dateStart = String(dateStartString.split(separator: ".").first ?? "").toDate(format: "yyyy-MM-dd'T'HH:mm:ss") {
            dateRangeStartField.updateDateTime(to: dateStart)
        }
        if let dateEndString = viewModel.dateRangeEnd.value,
           let dateEnd = String(dateEndString.split(separator: ".").first ?? "").toDate(format: "yyyy-MM-dd'T'HH:mm:ss") {
            dateRangeEndField.updateDateTime(to: dateEnd)
        }
        viewModel.placeType.send(viewModel.placeType.value)
        viewModel.nature.send(viewModel.nature.value)
        viewModel.state.send(viewModel.state.value)
        viewModel.city.send(viewModel.city.value)
        viewModel.agency.send(viewModel.agency.value)
        if viewModel.person.value != nil {
            myOccurrencesField.isChecked = true
        }
        streetField.textField.text = viewModel.street.value
        districtField.textField.text = viewModel.district.value
        referencePointField.textField.text = viewModel.referencePoint.value
        involvedNameField.textField.text = viewModel.involvedName.value
        involvedCpfField.textField.text = viewModel.involvedCpf.value
        vehiclePlateField.textField.text = viewModel.vehiclePlate.value

        if let birthDateString = viewModel.involvedBirthdate.value,
           let birthDate = birthDateString.toDate(format: "yyyy-MM-dd") {
            involvedBirthdateField.updateDate(to: birthDate)
        }
        involvedMotherNameField.textField.text = viewModel.involvedMotherName.value
    }

    @objc func stateFieldBeginEditing(_ sender: UITextField) {
        let searchController = StaticSearchViewController(
            inputText: sender,
            data: statesData.map { state in (key: state.id, value: "\(state.name) - \(state.id)") }
        )
        searchController.onSelect = { selected in
            self.viewModel.state.send(selected.key)
            self.viewModel.city.send("")
            self.cityField.textField.text = nil
            if selected.key.isEmpty {
                self.cityFieldLine.isHidden = true
            } else {
                self.cityFieldLine.isHidden = false
            }
            self.reloadData()
            self.populateCities(forState: selected.key)
        }
        parentViewController.present(searchController, animated: true)
    }

    @objc func cityFieldBeginEditing(_ sender: UITextField) {
        let searchController = StaticSearchViewController(
            inputText: sender,
            data: citiesData.map { city in (key: String(city.ibgeCode), value: city.name) }
        )
        searchController.onSelect = { selected in
            self.viewModel.city.send(selected.key)
        }
        parentViewController.present(searchController, animated: true)
    }

    @objc func naturesFieldBeginEditing(_ sender: UITextField) {
        let searchController = StaticSearchViewController(
            inputText: sender,
            data: naturesData.map { nature in (key: nature.id.uuidString, value: nature.name) }
        )
        searchController.onSelect = { selected in
            self.viewModel.nature.send(selected.key)
        }
        parentViewController.present(searchController, animated: true)
    }

    @objc func agenciesFieldBeginEditing(_ sender: UITextField) {
        let searchController = StaticSearchViewController(
            inputText: sender,
            data: agenciesData.map { agency in
                (key: agency.id, value: "\(agency.initials) - \(agency.name)" )
            }
        )
        searchController.onSelect = { selected in
            if selected.value.isEmpty {
                self.viewModel.agency.send(nil)
                self.selectedAgencyId = nil
                self.naturesSection.disabled = true
                self.agencyField.clear()
                self.operatingRegionsSection.disabled = true
            } else {
                self.viewModel.agency.send(selected.key)
                self.selectedAgencyId = selected.key
                self.naturesSection.disabled = false
                self.operatingRegionsSection.disabled = false
            }
        }
        parentViewController.present(searchController, animated: true)
    }

    @objc func placeTypesFieldBeginEditing(_ sender: UITextField) {
        let searchController = StaticSearchViewController(
            inputText: sender,
            data: placeTypesData.map { placeType in (key: placeType.code, value: placeType.description) }
        )
        searchController.onSelect = { selected in
            self.viewModel.placeType.send(selected.key)
        }
        parentViewController.present(searchController, animated: true)
    }

    func getInfo() -> [String: String] {
        var info = [String: String]()
        formSections.forEach { section in
            for (title, value) in section.getInfo() {
                info[title.trimmingCharacters(in: .whitespacesAndNewlines)] = value
            }
        }
        return info
    }

    func clear() {
        if naturesSection.isExpanded {
            handleToggleSize(inSection: 1)
        }
        if operatingRegionsSection.isExpanded {
            handleToggleSize(inSection: 2)
        }
        naturesSection.disabled = true
        operatingRegionsSection.disabled = true
        fields.forEach { $0.clear() }
    }
}
