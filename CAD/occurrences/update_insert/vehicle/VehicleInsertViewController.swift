//
//  VehicleInsertViewController.swift
//  CAD
//
//  Created by Samir Chaves on 21/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class VehicleInsertViewController: OccurrenceInsertViewController<VehicleUpdate> {
    internal var form: VehicleForm!
    internal var naturesField: OccurrenceNaturesUpdate<Vehicle>!
    private let agencyId: String
    private let occurrenceId: UUID
    private let teamId: UUID
    private let vehicleWithNatures: OccurrenceNatures<Vehicle>
    private var model: VehicleUpdate
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

        vehicleWithNatures = OccurrenceNatures<Vehicle>(
            objects: [],
            component: Vehicle(
                id: UUID(),
                version: 0,
                externalID: nil,
                characteristics: nil,
                chassis: nil,
                moveCondition: nil,
                color: nil,
                involvement: nil,
                escaped: nil,
                brand: nil,
                model: nil,
                natures: [],
                plate: nil,
                restriction: nil,
                robberyTheft: nil,
                type: nil,
                bondWithInvolved: nil,
                note: nil
            )
        )
        model = vehicleWithNatures.component.toUpdate(teamId: teamId, idsVersions: [])

        super.init(name: "Veículo")

        self.form = VehicleForm(vehicleUpdate: model, parentViewController: self)

        naturesField = OccurrenceNaturesUpdate(
            occurrenceId: occurrenceId,
            occurrenceNatures: occurrenceNatures,
            agencyId: agencyId,
            teamId: teamId,
            object: vehicleWithNatures,
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
        let naturesInvolvements = naturesField.selectedNatures.map { selectedNature -> NatureInvolvement? in
            selectedNature.situation.map {
                NatureInvolvement(involvement: $0, nature: selectedNature.id)
            }
        }.compactMap { $0 }

        let vehicleInsert = model.toInsert(naturesAndInvolvements: naturesInvolvements)
        startLoading()
        naturesField.addNewNaturesToOccurrence {
            self.occurrenceService.addVehicle(occurrenceId: self.occurrenceId, vehicle: vehicleInsert) { result in
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
