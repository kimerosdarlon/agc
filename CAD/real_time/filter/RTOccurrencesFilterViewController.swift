//
//  RTOccurrencesFilterViewController.swift
//  CAD
//
//  Created by Samir Chaves on 17/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class RTOccurrencesFilterViewController: UITableViewController, RTFilterViewController {
    private var formSections: [FormSection]
    private let dataSource: RecentOccurrencesDataSource

    private let timeField = TagsFieldComponent<Int>(tags: [], multipleChoice: false)
    private let priorityField = TagsFieldComponent<OccurrencePriority>(tags: [], multipleChoice: true)
    private let situationField = TagsFieldComponent<OccurrenceSituation>(tags: [], multipleChoice: true)
    private let operatingRegionField = TagsFieldComponent<UUID>(tags: [], multipleChoice: true)
    private let natureField = TagsFieldComponent<UUID>(tags: [], multipleChoice: true)
    private let placeTypeField = TagsFieldComponent<Int>(tags: [], multipleChoice: true)
    private let teamField = TagsFieldComponent<UUID>(tags: [], multipleChoice: true)

    private let timeSection: FormSection
    private let prioritySection: FormSection
    private let situationSection: FormSection
    private let operatingRegionSection: FormSection
    private let naturesSection: FormSection
    private let placeTypeSection: FormSection
    private let teamSection: FormSection

    private var filters = RecentOccurrencesDataSource.RecentOccurrenceFilter()
    
    required init(dataSource: RecentOccurrencesDataSource) {
        self.dataSource = dataSource
        timeSection = FormSection(title: "Tempo decorrido", lines: [
            FormLine(timeField)
        ], isExpanded: true)
        prioritySection = FormSection(title: "Prioridade", lines: [
            FormLine(priorityField)
        ], isExpanded: true)
        situationSection = FormSection(title: "Situação da ocorrência", lines: [
            FormLine(situationField)
        ], isExpanded: true)
        operatingRegionSection = FormSection(title: "Região de atuação", lines: [
            FormLine(operatingRegionField)
        ], isExpanded: true)
        naturesSection = FormSection(title: "Natureza", lines: [
            FormLine(natureField)
        ], isExpanded: true)
        placeTypeSection = FormSection(title: "Tipo de Local", lines: [
            FormLine(placeTypeField)
        ], isExpanded: true)
        teamSection = FormSection(title: "Equipes", lines: [
            FormLine(teamField)
        ], isExpanded: true)
        formSections = [
            timeSection,
            prioritySection,
            situationSection,
            operatingRegionSection,
            naturesSection,
            placeTypeSection,
            teamSection
        ]
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .appBackground
        tableView.register(FormFieldCell.self, forCellReuseIdentifier: FormFieldCell.identifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func didClean() {
        timeField.clear()
        priorityField.clear()
        situationField.clear()
        operatingRegionField.clear()
        natureField.clear()
        placeTypeField.clear()
        teamField.clear()
        filters = RecentOccurrencesDataSource.RecentOccurrenceFilter()
        dataSource.filter(filters)
    }

    private func openSection(_ sectionIndex: Int) {
        for (i, section) in formSections.enumerated() where sectionIndex != i {
            section.isExpanded = false
        }
        tableView.reloadData()
    }

    private func openAllSections() {
        for section in formSections {
            section.isExpanded = true
        }
        tableView.reloadData()
    }

    private func setupFields() {
        timeField.onSelect = { (_, selected) in
            self.filters[.time] = selected.map { $0.key }
            self.dataSource.filter(self.filters)
        }

        priorityField.onSelect = { (_, selected) in
            self.filters[.priority] = selected.map { $0.key }
            self.dataSource.filter(self.filters)
        }

        situationField.onSelect = { (_, selected) in
            self.filters[.situation] = selected.map { $0.key }
            self.dataSource.filter(self.filters)
        }

        placeTypeField.onSelect = { (_, selected) in
            self.filters[.placeType] = selected.map { $0.key }
            self.dataSource.filter(self.filters)
        }

        natureField.onSelect = { (_, selected) in
            self.filters[.nature] = selected.map { $0.key }
            self.dataSource.filter(self.filters)
        }

        operatingRegionField.onSelect = { (_, selected) in
            self.filters[.operatingRegion] = selected.map { $0.key }
            self.dataSource.filter(self.filters)
        }

        teamField.onSelect = { (_, selected) in
            self.filters[.team] = selected.map { $0.key }
            self.dataSource.filter(self.filters)
        }
    }

    private func setupFieldsData() {

        let priorities = dataSource.priorities().map { (key: $0, value: $0.rawValue) }
        priorityField.setTags(priorities)
        prioritySection.disabled = priorities.isEmpty

        timeField.setTags([
            (key: 24, value: "há mais de 24 horas"),
            (key: 12, value: "há 12 horas"),
            (key: 6, value: "há 06 horas"),
            (key: 1, value: "última hora")
        ])
        timeSection.disabled = priorities.isEmpty

        let situations = dataSource.situations().map { (key: $0, value: $0.rawValue) }
        situationField.setTags(situations)
        situationSection.disabled = situations.isEmpty

        let placeTypes = dataSource.placeTypes().map { placeType in
            (key: Int(placeType.code) ?? -1, value: placeType.description)
        }
        placeTypeSection.disabled = placeTypes.isEmpty
        placeTypeField.setTags(placeTypes)

        let natures = dataSource.natures().map { (key: $0.id, value: $0.name) }
        naturesSection.disabled = natures.isEmpty
        natureField.setTags(natures)

        let operatingRegions = dataSource.operatingRegions().map { (key: $0.id, value: $0.name) }
        operatingRegionSection.disabled = operatingRegions.isEmpty
        operatingRegionField.setTags(operatingRegions)

        let teams = dataSource.teams().map { (key: $0.id, value: $0.name) }
        teamField.setTags(teams)
        teamSection.disabled = teams.isEmpty

        tableView.reloadData()
    }

    private func highlightSelected() {
        timeField.selectTags(Set(filters[.time] as? [Int] ?? []))
        timeField.highlightSelectedCells()

        priorityField.selectTags(Set(filters[.priority] as? [OccurrencePriority] ?? []))
        priorityField.highlightSelectedCells()

        situationField.selectTags(Set(filters[.situation] as? [OccurrenceSituation] ?? []))
        situationField.highlightSelectedCells()

        placeTypeField.selectTags(Set(filters[.placeType] as? [Int] ?? []))
        placeTypeField.highlightSelectedCells()

        natureField.selectTags(Set(filters[.nature] as? [UUID] ?? []))
        natureField.highlightSelectedCells()

        operatingRegionField.selectTags(Set(filters[.operatingRegion] as? [UUID] ?? []))
        operatingRegionField.highlightSelectedCells()

        teamField.selectTags(Set(filters[.team] as? [UUID] ?? []))
        teamField.highlightSelectedCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFieldsData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.highlightSelected()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        view.backgroundColor = .appBackground
        title = "Ocorrências"
        tableView.separatorStyle = .none
        setupFields()
        setupFieldsData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.openSection(-1)
            self?.highlightSelected()
        }
    }
}

extension RTOccurrencesFilterViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        formSections.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
                            tableView.insertRows(at: indexPaths, with: .top)
                            formSection.lines.forEach { $0.view.layoutIfNeeded() }
                        } else {
                            tableView.deleteRows(at: indexPaths, with: .top)
                        }
                    } else if formSection.isExpanded {
                        formSection.isExpanded = false
                        tableView.deleteRows(at: indexPaths, with: .top)
                    }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let formSection = formSections[section]
        if !formSection.isExpanded {
            return 0
        }
        return formSection.lines.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let formSection = formSections[section]
        if formSection.isStatic {
            return 0
        }
        return 60
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let line = formSections[indexPath.section].lines[indexPath.row]
        if line.isHidden {
            return 0
        } else {
            return line.getHeight()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.identifier, for: indexPath) as! FormFieldCell
        let formLine = formSections[indexPath.section].lines[indexPath.row]
        cell.setup(field: formLine.view)
        cell.backgroundColor = .appBackground
        cell.contentView.backgroundColor = .appBackground
        cell.selectionStyle = .none
        return cell
    }
}
