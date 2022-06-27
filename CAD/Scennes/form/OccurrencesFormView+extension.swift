//
//  OccurrencesFormFields.swift
//  CAD
//
//  Created by Samir Chaves on 20/04/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

// Handling data population
extension OccurrencesFormView {
    internal func populateStates() {
        self.stateField.state = .loading
        let states = placesService.getStates()
        self.statesData = states
        self.stateField.state = .ready
        if let stateInitials = self.viewModel.state.value,
           let state = states.first(where: { $0.initials == stateInitials }) {
            self.stateField.textField.text = "\(state.name) - \(state.id)"
            self.cityFieldLine.isHidden = false
            self.populateCities(forState: stateInitials)
        } else {
            self.cityFieldLine.isHidden = true
        }
        self.reloadData()
    }

    internal func populateCities(forState stateId: String) {
        self.cityField.state = .loading
        let cities = placesService.getCitiesFor(state: stateId)
        self.citiesData = cities
        self.cityField.state = .ready
        if let cityCode = self.viewModel.city.value,
           let city = cities.first(where: { $0.ibgeCode == Int(cityCode) }) {
            self.cityField.textField.text = city.name
            self.beginUpdates()
            self.endUpdates()
        }
    }

    internal func populateAgencies() {
        self.agencyField.state = .loading
        cadService.getAgencies { result in
            garanteeMainThread {
                switch result {
                case .success(let agencies):
                    self.agenciesData = agencies
                    self.agencyField.state = .ready
                    if let agencyId = self.viewModel.agency.value,
                       let agency = agencies.first(where: { $0.id.elementsEqual(agencyId) }) {
                        self.beginUpdates()
                        self.agencyField.textField.text = "\(agency.initials) - \(agency.name)"
                        self.selectedAgencyId = agencyId
                        self.naturesSection.disabled = false
                        self.operatingRegionsSection.disabled = false
                        self.endUpdates()
                    }
                case .failure(let error as NSError):
                    self.agencyField.state = .error(error.domain)
                    if self.parentViewController.isUnauthorized(error) {
                        self.parentViewController.gotoLogin(error.domain)
                    }
                    self.agenciesData = []
                }
            }
        }
    }

    internal func populateNatures(agencyId: String) {
        self.natureField.state = .loading
        cadService.getNatures(agencyId: agencyId) { result in
            garanteeMainThread {
                switch result {
                case .success(let natures):
                    self.naturesData = natures
                    self.natureField.state = .ready
                    if let initialNatureId = self.viewModel.nature.value,
                       let initialNature = self.naturesData.first(where: { $0.id.uuidString.elementsEqual(initialNatureId) }) {
                        self.natureField.textField.text = initialNature.name
                    }
                case .failure(let error as NSError):
                    self.natureField.state = .error(error.domain)
                    if self.parentViewController.isUnauthorized(error) {
                        self.parentViewController.gotoLogin(error.domain)
                    }
                    self.naturesData = []
                }

                self.beginUpdates()
                self.endUpdates()
            }
        }
    }

    internal func populateSituations() {
        self.situationsField.state = .loading
        domainService.getOccurrenceValues { result in
            garanteeMainThread {
                switch result {
                case .success(let occurrencesDomain):
                    let tags = occurrencesDomain.situations.map { (key: $0.option, value: $0.label) }
                    self.situationsField.setTags(tags)
                case .failure(let error as NSError):
                    self.situationsField.setTags([])
                    self.situationsField.state = .error(error.domain)
                    if self.parentViewController.isUnauthorized(error) {
                        self.parentViewController.gotoLogin(error.domain)
                    }
                }

                self.beginUpdates()
                self.endUpdates()
                self.situationsField.selectTags(Set(self.viewModel.situations.value))
                self.situationsField.reloadData()
            }
        }
    }

    internal func populateOperatingRegions(agencyId: String) {
        self.operatingRegionsField.state = .loading
        cadService.getOperatingRegions(agencyId: agencyId) { result in
            garanteeMainThread {
                switch result {
                case .success(let operatingRegions):
                    let tags = operatingRegions.map { (key: $0.id.uuidString, value: $0.initials) }
                    self.operatingRegionsField.setTags(tags)
                case .failure(let error as NSError):
                    self.operatingRegionsField.state = .error(error.domain)
                    if self.parentViewController.isUnauthorized(error) {
                        self.parentViewController.gotoLogin(error.domain)
                    }
                    self.operatingRegionsField.setTags([])
                }

                self.beginUpdates()
                self.endUpdates()
                self.operatingRegionsField.selectTags(Set(self.viewModel.operatingRegions.value))
                self.operatingRegionsField.reloadData()
            }
        }
    }

    internal func populatePlaceTypes() {
        occurrenceService.placeTypes { result in
            garanteeMainThread {
                switch result {
                case .success(let placeTypes):
                    self.placeTypesData = placeTypes
                    if let initialPlaceTypeCode = self.viewModel.placeType.value,
                       let initialPlaceType = placeTypes.first(where: { $0.code == initialPlaceTypeCode }) {
                        self.placeTypeField.textField.text = initialPlaceType.description
                    }
                case .failure(let error as NSError):
                    if self.parentViewController.isUnauthorized(error) {
                        self.parentViewController.gotoLogin(error.domain)
                    }
                    self.placeTypesData = []
                }
            }
        }
    }
}

extension OccurrencesFormView: CadFilterViewModelDelegate {
    func didFieldValueChange() {
        formSections.forEach { $0.updateFillCount() }
    }
}

// Table View delegate and data source
extension OccurrencesFormView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        formSections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = formSections[section].header
        header?.onTap = {
            self.handleToggleSize(inSection: section)
        }
        return header
    }

    func handleToggleSize(inSection section: Int) {
        if !formSections[section].disabled {
            for sectionIndex in 0..<self.formSections.count {
                let formSection = formSections[sectionIndex]

                if !formSection.isStatic {
                    let indexPaths = formSection.lines.indices.map { row in
                        IndexPath(row: row, section: sectionIndex)
                    }

                    if sectionIndex == section {
                        formSection.isExpanded = !formSection.isExpanded
                        if formSection.isExpanded {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if formSection.title.elementsEqual("Regiões de Atuação") {
                                    self.operatingRegionsField.highlightSelectedCells()
                                    self.beginUpdates()
                                    self.endUpdates()
                                }
                                if formSection.title.elementsEqual("Dados Gerais") {
                                    self.situationsField.highlightSelectedCells()
                                    self.beginUpdates()
                                    self.endUpdates()
                                }
                            }
                            insertRows(at: indexPaths, with: .top)
                        } else {
                            deleteRows(at: indexPaths, with: .top)
                        }
                    } else if formSection.isExpanded {
                        formSection.isExpanded = false
                        deleteRows(at: indexPaths, with: .top)
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let formSection = formSections[section]
        if !formSection.isExpanded {
            return 0
        }
        return formSection.lines.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let formSection = formSections[section]
        if formSection.isStatic {
            return 0
        }

        if formSection.title == "Regiões de Atuação" {
            return 70
        }
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let line = formSections[indexPath.section].lines[indexPath.row]
        if line.isHidden {
            return 0
        } else {
            return line.getHeight()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: FormFieldCell.identifier, for: indexPath) as! FormFieldCell
        let formLine = formSections[indexPath.section].lines[indexPath.row]
        cell.setup(field: formLine.view)
        cell.backgroundColor = .appBackground
        cell.contentView.backgroundColor = .appBackground
        cell.selectionStyle = .none
        return cell
    }
}
