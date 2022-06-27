//
//  DriverGeneralDetailViewController.swift
//  Driver
//
//  Created by Samir Chaves on 16/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation

import AgenteDeCampoCommon
import AgenteDeCampoModule
import UIKit

protocol DriverGeneralDetailDelegate: class {
    func didTapOnExpirationWarning()
}

class DriverGeneralDetailViewController: DriverDetailPageViewController {
    private var detail: Driver!
    private let dateFormatter = DateFormatter()
    private let datetimeFormatter = DateFormatter()
    weak var detailsDelegate: DriverGeneralDetailDelegate?

    init(with generalDriverDetail: Driver) {
        super.init()
        detail = generalDriverDetail
        title = "Dados Gerais"
        dateFormatter.dateFormat = "dd/MM/yyyy"
        datetimeFormatter.locale = Locale(identifier: "pt_BR")
        datetimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        datetimeFormatter.timeZone = TimeZone(identifier: "UTC")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buildDetailViewContainer() -> UIView {
        let view = UIView(frame: .zero)
        view.enableAutoLayout()
        view.backgroundColor = .appBackground
        return view
    }

    private func fillBlankField(_ value: String?) -> String {
        value == nil ? "————" : value!.fillEmpty()
    }

    private func formatDate(_ dateOpt: Date?) -> String {
        if let date = dateOpt {
            return dateFormatter.string(from: date)
        }

        return "————"
    }

    private func getCourseGroup(_ course: Course?, withTitle title: String) -> DetailsGroup {
        let date = course?.date != nil ? "\(formatDate(datetimeFormatter.date(from: course!.date!)))" : fillBlankField(nil)
        let uf = fillBlankField(course?.uf)
        let description = fillBlankField(course?.description)
        return DetailsGroup(items: [
            [(title: "Data", detail: date), (title: "Estado", detail: uf)],
            [(title: "Descrição", detail: description)]
        ], withHeader: title)
    }

    private func getCourse(fromList list: [Course], withName name: String) -> Course? {
        if let index = list.firstIndex(where: { $0.type == name }) {
            return list[index]
        }

        return nil
    }

    @objc private func onTapWarning() {
        self.detailsDelegate?.didTapOnExpirationWarning()
    }

    private func getDetailsBlock() -> DetailsBlock {
        let firstCnhDate = datetimeFormatter.date(from: detail.general.firstCnh.date)
        let expirationDate = datetimeFormatter.date(from: detail.general.currentCnh.expirationDate)
        let issueDate = datetimeFormatter.date(from: detail.general.currentCnh.issueDate ?? "")

        let cnhCourse = getCourse(fromList: detail.courses, withName: "Renovação CNH")
        let recicleCourse = getCourse(fromList: detail.courses, withName: "Reciclagem Infrator")
        let tveCourse = getCourse(fromList: detail.courses, withName: "Tve")
        let cnhWarning = detail.general.currentCnh.cnhWarning

        var items: [[InteractableDetailItem]] = [
            InteractableDetailItem.noInteraction(
                [(title: "Nº CNH", detail: detail.general.currentCnh.number.fillEmpty()), (title: "Número de Registro", detail: detail.general.currentCnh.registrationNumber.fillEmpty())]
            ),
            [
                InteractableDetailItem.noInteraction((title: "Categoria Atual", detail: detail.general.currentCnh.category.current.fillEmpty())),
                InteractableDetailItem(
                    fromItem: (title: "Validade", detail: formatDate(expirationDate)),
                    hasInteraction: false,
                    hasWarning: cnhWarning != nil,
                    onTap: cnhWarning.map { _ in UITapGestureRecognizer(target: self, action: #selector(onTapWarning)) }
                )
            ]
        ]

        items.append(contentsOf: InteractableDetailItem.noInteraction([
            [(title: "Data 1ª Habilitação", detail: formatDate(firstCnhDate)), (title: "RENACH", detail: detail.general.renach.fillEmpty())],
            [(title: "UF de Emissão", detail: detail.general.currentCnh.uf.fillEmpty()), (title: "Data de Emissão", detail: formatDate(issueDate))],
            [(title: "Categoria Rebaixada", detail: detail.general.currentCnh.category.demoted.fillEmpty())],
            [(title: "Motivo de Requerimento", detail: detail.cnhRequirements.joined(separator: "\n").fillEmpty())],
            [(title: "Motivo de Requerimento PID", detail: detail.pidRequirements.joined(separator: ", ").fillEmpty())],
            [(title: "Descrição CNH", detail: detail.general.currentCnh.status.fillEmpty()), (title: "Descrição CNH Anterior", detail: detail.general.lastCnhStatus.fillEmpty())],
            [(title: "Classificação Curso TVE", detail: fillBlankField(tveCourse?.description))]
        ]))

        let detailsGroup = DetailsGroup(items: items)

        let cnhCourseGroup = getCourseGroup(cnhCourse, withTitle: "Curso Atualização Renovação CNH")
        let recicleCourseGroup = getCourseGroup(recicleCourse, withTitle: "Curso Atualização Reciclagem Infrator")

        var foreignCnhItems = [[DetailItem]]()
        if let foreignCnh = detail.general.foreignCnh {
            var details = [DetailItem]()

            details.append((title: "País de Origem", detail: (foreignCnh.country ?? "").fillEmpty()))

            if let foreignCnhDate = foreignCnh.date {
                let foreignCnhDate = datetimeFormatter.date(from: foreignCnhDate)
                details.append((title: "Validade", detail: formatDate(foreignCnhDate)))
            } else {
                details.append((title: "Validade", detail: "————"))
            }

            foreignCnhItems.append(details)
            foreignCnhItems.append([
                (title: "Identificação", detail: fillBlankField(foreignCnh.id ?? "")),
                (title: "Registro Nacional", detail: fillBlankField(detail.general.rne))
            ])
        }
        let foreignCnhGroup = DetailsGroup(items: foreignCnhItems, withHeader: "Habilitação Extrangeira")

        return DetailsBlock(groups: [
            detailsGroup,
            cnhCourseGroup,
            recicleCourseGroup,
            foreignCnhGroup
        ], identifier: "details")
    }

    func getNotesBlock() -> DetailsBlock {
        DetailsBlock(item: (title: "Observações", detail: detail.general.observations), identifier: "notes")
    }

    func getMedicalRestrictionsBlock() -> DetailsBlock {
        DetailsBlock(item: (title: "Restrições Médicas", detail: fillBlankField(detail.general.medicRestrictions)), identifier: "medicalRestrictions")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    override func viewDidLoad() {
        let listBuilder = ListBasedDetailBuilder(into: scrollContainer)
        view.addSubview(scrollContainer)

        let detailsBlocks = [
            getDetailsBlock(),
            getNotesBlock(),
            getMedicalRestrictionsBlock()
        ]

        listBuilder.buildDetailsBlocks(detailsBlocks)
        scrollContainer.width(view)

        NSLayoutConstraint.activate([
            scrollContainer.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollContainer.bottomAnchor, multiplier: 1)
        ])
        listBuilder.setupLayout()
    }
}
