//
//  InvolvedInsertViewController.swift
//  CAD
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class InvolvedInsertViewController: OccurrenceInsertViewController<InvolvedUpdate> {
    internal var form: InvolvedForm!
    internal var naturesField: OccurrenceNaturesUpdate<Involved>!
    private let agencyId: String
    private let occurrenceId: UUID
    private let teamId: UUID
    private let involvedWithNatures: OccurrenceNatures<Involved>
    private var model: InvolvedUpdate
    private let attachsFeedback = InsertAttachmentsFeedbackView().enableAutoLayout()

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    init(occurrenceId: UUID,
         occurrenceNatures: [Nature],
         agencyId: String,
         teamId: UUID) {
        self.occurrenceId = occurrenceId
        self.teamId = teamId
        self.agencyId = agencyId

        involvedWithNatures = OccurrenceNatures<Involved>(
            objects: [],
            component: Involved(
                id: UUID(),
                version: 0,
                externalId: nil,
                birthDate: nil,
                involvement: nil,
                natures: [],
                name: nil,
                motherName: nil,
                documentNumber: nil,
                warrantNumber: nil,
                colorRace: nil,
                gender: nil,
                organInitials: nil,
                documentType: nil,
                note: nil
            )
        )
        model = involvedWithNatures.component.toUpdate(teamId: teamId, idsVersions: [])

        super.init(name: "Envolvido")

        self.form = InvolvedForm(involvedUpdate: model, parentViewController: self)

        naturesField = OccurrenceNaturesUpdate(
            occurrenceId: occurrenceId,
            occurrenceNatures: occurrenceNatures,
            agencyId: agencyId,
            teamId: teamId,
            object: involvedWithNatures,
            parentViewController: self,
            forInsert: true
        )

        form.formBuilder.listenForChanges {
            self.model = self.form.formBuilder.model
        }

        form.formBuilder.listenForChanges(in: \.birthDate) { birthDateText in
            guard let birthDateText = birthDateText else { return }
            let birthDate = birthDateText.toDate(format: "yyyy-MM-dd")
            let age = birthDate?.difference(to: Date(), [.year]).year
            self.model.age = age.map { "\($0)" }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSave() {
        let naturesInvolvements = naturesField.selectedNatures.map { selectedNature -> NatureInvolvement? in
            selectedNature.situation.map {
                NatureInvolvement(involvement: $0, nature: selectedNature.id)
            }
        }.compactMap { $0 }

        let involvedInsert = model.toInsert(naturesAndInvolvements: naturesInvolvements)
        startLoading()
        naturesField.addNewNaturesToOccurrence {
            self.occurrenceService.addInvolved(occurrenceId: self.occurrenceId, involved: involvedInsert) { result in
                garanteeMainThread {
                    self.stopLoading()
                    switch result {
                    case .success:
                        self.showSuccessAlert()
                    case .failure(let error as NSError):
                        self.showErrorAlert(title: "Erro ao salvar", message: error.domain)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        naturesField.enableAutoLayout()
        container.addSubview(naturesField)
        form.formView.enableAutoLayout()
        container.addSubview(form.formView)
        container.addSubview(attachsFeedback)

        NSLayoutConstraint.activate([
            naturesField.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -30),
            naturesField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            naturesField.topAnchor.constraint(equalTo: container.topAnchor),

            form.formView.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -20),
            form.formView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            form.formView.topAnchor.constraint(equalTo: naturesField.bottomAnchor, constant: 5),

            attachsFeedback.topAnchor.constraint(equalTo: form.formView.bottomAnchor),
            attachsFeedback.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            attachsFeedback.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -30),
            container.bottomAnchor.constraint(equalTo: attachsFeedback.bottomAnchor, constant: 5)
        ])
    }
}
