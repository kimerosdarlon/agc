//
//  DrugInsertViewController.swift
//  CAD
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class DrugInsertViewController: OccurrenceInsertViewController<DrugUpdate> {
    internal var form: DrugForm!
    internal var naturesField: OccurrenceNaturesUpdate<Drug>!
    private let agencyId: String
    private let occurrenceId: UUID
    private let teamId: UUID
    private let drugWithNatures: OccurrenceNatures<Drug>
    private var model: DrugUpdate
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

        drugWithNatures = OccurrenceNatures<Drug>(
            objects: [],
            component: Drug(
                id: UUID(),
                version: 0,
                natures: [],
                externalId: nil,
                destination: nil,
                package: nil,
                note: nil,
                amount: nil,
                situation: nil,
                apparentType: nil,
                measureUnit: nil,
                bondWithInvolved: nil
            )
        )
        model = drugWithNatures.component.toUpdate(teamId: teamId, idsVersions: [])

        super.init(name: "Droga")

        self.form = DrugForm(drugUpdate: model, parentViewController: self)

        naturesField = OccurrenceNaturesUpdate(
            occurrenceId: occurrenceId,
            occurrenceNatures: occurrenceNatures,
            agencyId: agencyId,
            teamId: teamId,
            object: drugWithNatures,
            parentViewController: self,
            forInsert: true
        )

        form.formBuilder.listenForChanges {
            self.model = self.form.formBuilder.model
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didSave() {
        let objectSituations = naturesField.selectedNatures.map { selectedNature -> ObjectSituation? in
            selectedNature.situation.map {
                ObjectSituation(situation: $0, nature: selectedNature.id, natureName: selectedNature.nature)
            }
        }.compactMap { $0 }

        let drugInsert = model.toInsert(objectSituations: objectSituations)
        startLoading()
        naturesField.addNewNaturesToOccurrence {
            self.occurrenceService.addDrug(occurrenceId: self.occurrenceId, drug: drugInsert) { result in
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
