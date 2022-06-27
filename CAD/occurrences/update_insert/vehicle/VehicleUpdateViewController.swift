//
//  OccurrenceVehicleUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class VehicleUpdateViewController: OccurrenceUpdateViewController<VehicleUpdate> {

    internal var form: VehicleForm!
    internal var naturesField: OccurrenceNaturesUpdate<Vehicle>!
    private let agencyId: String
    private let occurrenceId: UUID
    private let teamId: UUID
    private let vehicleWithNatures: OccurrenceNatures<Vehicle>
    private var galleryField: GalleryField!

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    init(occurrenceId: UUID,
         occurrenceNatures: [Nature],
         agencyId: String,
         teamId: UUID,
         vehicleWithNatures: OccurrenceNatures<Vehicle>) {
        self.vehicleWithNatures = vehicleWithNatures
        self.occurrenceId = occurrenceId
        self.teamId = teamId
        self.agencyId = agencyId

        let vehicle = vehicleWithNatures.component
        let vehicleUpdate = vehicle.toUpdate(
            teamId: teamId,
            idsVersions: vehicleWithNatures.objects.map { vehicle in
                IdVersion(id: vehicle.id, version: vehicle.version)
            }
        )

        super.init(model: vehicleUpdate, name: "Veículo", version: vehicle.version, canDelete: true)

        self.galleryField = GalleryField(label: "Anexos", entityId: vehicle.externalID ?? vehicle.id, parentViewController: self)
        self.form = VehicleForm(vehicleUpdate: vehicleUpdate, parentViewController: self)

        naturesField = OccurrenceNaturesUpdate(
            occurrenceId: occurrenceId,
            occurrenceNatures: occurrenceNatures,
            agencyId: agencyId,
            teamId: teamId,
            object: vehicleWithNatures,
            parentViewController: self
        )

        form.formBuilder.listenForChanges {
            self.model = self.form.formBuilder.model

            if self.form.formBuilder.isMerging {
                guard let currentVersion = self.remoteModel?.vehicles.first?.version else { return }
                let conflictingFields = self.getConflictingFields()
                self.form.formBuilder.setConflictsTo(fieldsKeys: conflictingFields, version: currentVersion)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didRemoveItem() {
        let idsVersions = naturesField.selectedNatures.map { IdVersion(id: $0.id, version: $0.version) }
        let vehicle = VehicleDelete(externalId: vehicleWithNatures.component.externalID, teamId: teamId, vehicles: idsVersions)
        startLoading()
        occurrenceService.delete(occurrenceId: occurrenceId, vehicle: vehicle) { error in
            garanteeMainThread {
                self.stopLoading()
                if let error = error as NSError? {
                    if self.isUnauthorized(error) {
                        NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                        return
                    }
                    Toast.present(in: self, message: error.domain)
                } else {
                    self.navigationController?.popViewController(animated: true)
                    self.updateDelegate?.didSave()
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
        galleryField.enableAutoLayout()
        container.addSubview(galleryField)

        NSLayoutConstraint.activate([
            naturesField.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -30),
            naturesField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            naturesField.topAnchor.constraint(equalTo: container.topAnchor),

            form.formView.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -20),
            form.formView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            form.formView.topAnchor.constraint(equalTo: naturesField.bottomAnchor, constant: 10),

            galleryField.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -20),
            galleryField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            galleryField.topAnchor.constraint(equalTo: form.formView.bottomAnchor, constant: 10),
            galleryField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])
    }

    private func getConflictingFields() -> [PartialKeyPath<VehicleUpdate>: String?] {
        guard let remoteVehicle = self.remoteModel else { return [:] }
        let initialVehicle = self.initialModel
        let vehicle = self.model
        var conflictingFields = [PartialKeyPath<VehicleUpdate>: String?]()

        if initialVehicle.plate != vehicle.plate &&
            initialVehicle.plate != remoteVehicle.plate &&
            vehicle.plate != remoteVehicle.plate {
            conflictingFields[\VehicleUpdate.plate] = remoteVehicle.plate
        }
        if initialVehicle.brand != vehicle.brand &&
            initialVehicle.brand != remoteVehicle.brand &&
            vehicle.brand != remoteVehicle.brand {
            conflictingFields[\VehicleUpdate.brand] = remoteVehicle.brand
        }
        if initialVehicle.model != vehicle.model &&
            initialVehicle.model != remoteVehicle.model &&
            vehicle.model != remoteVehicle.model {
            conflictingFields[\VehicleUpdate.model] = remoteVehicle.model
        }
        if initialVehicle.chassis != vehicle.chassis &&
            initialVehicle.chassis != remoteVehicle.chassis &&
            vehicle.chassis != remoteVehicle.chassis {
            conflictingFields[\VehicleUpdate.chassis] = remoteVehicle.chassis
        }
        if initialVehicle.color != vehicle.color &&
            initialVehicle.color != remoteVehicle.color &&
            vehicle.color != remoteVehicle.color {
            conflictingFields[\VehicleUpdate.color] = remoteVehicle.color
        }
        if initialVehicle.escaped != vehicle.escaped &&
            initialVehicle.escaped != remoteVehicle.escaped &&
            vehicle.escaped != remoteVehicle.escaped {
            conflictingFields[\VehicleUpdate.escaped] = remoteVehicle.escaped.flatMap { option in
                form.dataSource.domainData?.escaped.first(where: { $0.option == option })?.label
            }
        }
        if initialVehicle.moveCondition != vehicle.moveCondition &&
            initialVehicle.moveCondition != remoteVehicle.moveCondition &&
            vehicle.moveCondition != remoteVehicle.moveCondition {
            conflictingFields[\VehicleUpdate.moveCondition] = remoteVehicle.moveCondition.flatMap { option in
                form.dataSource.domainData?.moveCondition.first(where: { $0.option == option })?.label
            }
        }
        if initialVehicle.restriction != vehicle.restriction &&
            initialVehicle.restriction != remoteVehicle.restriction &&
            vehicle.restriction != remoteVehicle.restriction {
            conflictingFields[\VehicleUpdate.restriction] = remoteVehicle.restriction
        }
        if initialVehicle.note != vehicle.note &&
            initialVehicle.note != remoteVehicle.note &&
            vehicle.note != remoteVehicle.note {
            conflictingFields[\VehicleUpdate.note] = remoteVehicle.note
        }
        if initialVehicle.characteristics != vehicle.characteristics &&
            initialVehicle.characteristics != remoteVehicle.characteristics &&
            vehicle.characteristics != remoteVehicle.characteristics {
            conflictingFields[\VehicleUpdate.characteristics] = remoteVehicle.characteristics
        }
        if initialVehicle.type != vehicle.type &&
            initialVehicle.type != remoteVehicle.type &&
            vehicle.type != remoteVehicle.type {
            conflictingFields[\VehicleUpdate.type] = remoteVehicle.type
        }
        if initialVehicle.robberyTheft != vehicle.robberyTheft &&
            initialVehicle.robberyTheft != remoteVehicle.robberyTheft &&
            vehicle.robberyTheft != remoteVehicle.robberyTheft {
            conflictingFields[\VehicleUpdate.robberyTheft] = remoteVehicle.robberyTheft
        }
        if initialVehicle.bondWithInvolved != vehicle.bondWithInvolved &&
            initialVehicle.bondWithInvolved != remoteVehicle.bondWithInvolved &&
            vehicle.bondWithInvolved != remoteVehicle.bondWithInvolved {
            conflictingFields[\VehicleUpdate.bondWithInvolved] = remoteVehicle.bondWithInvolved.flatMap { option in
                form.dataSource.domainData?.involvedLinks.first(where: { $0.option == option })?.label
            }
        }

        return conflictingFields
    }

    override func setupConflictingState() {
        guard let remoteVersion = remoteModel?.vehicles.first?.version else { return }
        let conflictingFields = self.getConflictingFields()
        form.formBuilder.setConflictsTo(fieldsKeys: conflictingFields, version: remoteVersion)
    }

    private func doubleCheckConflict() {
        self.occurrenceService.getOccurrenceById(self.occurrenceId) { result in
            garanteeMainThread {
                self.stopLoading()
                switch result {
                case .success(let details):
                    let currentVehicleId = self.model.externalId ?? self.vehicleWithNatures.component.id
                    let vehicle = details.vehicles
                        .first(where: { vehicle in
                            let vehicleId = vehicle.component.externalID ?? vehicle.component.id
                            return vehicleId == currentVehicleId
                        })
                    self.remoteModel = vehicle?.component
                        .toUpdate(teamId: self.teamId, idsVersions: vehicle?.objects.map {
                            IdVersion(id: $0.id, version: $0.version)
                        } ?? [])

                    self.model.vehicles = self.remoteModel?.vehicles ?? []
                    let conflictingFields = self.getConflictingFields()
                    if !conflictingFields.isEmpty {
                        self.showConflictAlert()
                    } else {
                        self.model.vehicles = self.remoteModel!.vehicles
                        self.updateOccurrence()
                    }
                case .failure(let error as NSError):
                    if self.isUnauthorized(error) {
                        NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                        return
                    }
                    self.showErrorAlert(title: "Erro durando a atualização", message: error.domain)
                }
            }
        }
    }

    private func updateOccurrence() {
        startLoading()
        occurrenceService.update(occurrenceId: occurrenceId, vehicle: self.model) { error in
            garanteeMainThread {
                if let error = error as NSError? {
                    if self.isUnauthorized(error) {
                        self.stopLoading()
                        NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                        return
                    }
                    if error.code == 422 && error.domain.lowercased().contains("conflito") {
                        self.doubleCheckConflict()
                    } else {
                        self.stopLoading()
                        self.showErrorAlert(title: "Erro durante a atualização", message: error.domain)
                    }
                } else {
                    self.stopLoading()
                    self.showSuccessAlert()
                }
            }
        }
    }

    func getResolvedModel() -> VehicleUpdate {
        guard let remoteModel = self.remoteModel else { return self.model }
        let mergeResult = form.formBuilder.getConflictsMerging()
        let resolvedMerge = mergeResult.filter { $0.value != nil } as! [PartialKeyPath<VehicleUpdate>: FieldConflictMergeStrategy]
        let fieldsResolvedAsTheirs = resolvedMerge.filter { $0.value == .theirs }.map { $0.key }

        let plateKeyPath = form.formBuilder.extractWritableKey(keyPath: \.plate)
        let brandKeyPath = form.formBuilder.extractWritableKey(keyPath: \.brand)
        let modelKeyPath = form.formBuilder.extractWritableKey(keyPath: \.model)
        let chassisKeyPath = form.formBuilder.extractWritableKey(keyPath: \.chassis)
        let colorKeyPath = form.formBuilder.extractWritableKey(keyPath: \.color)
        let escapedKeyPath = form.formBuilder.extractWritableKey(keyPath: \.escaped)
        let moveConditionKeyPath = form.formBuilder.extractWritableKey(keyPath: \.moveCondition)
        let restrictionKeyPath = form.formBuilder.extractWritableKey(keyPath: \.restriction)
        let noteKeyPath = form.formBuilder.extractWritableKey(keyPath: \.note)

        fieldsResolvedAsTheirs.forEach { keyPath in
            if keyPath == plateKeyPath {
                self.model[keyPath: plateKeyPath] = remoteModel[keyPath: plateKeyPath]
            }
            if keyPath == brandKeyPath {
                self.model[keyPath: brandKeyPath] = remoteModel[keyPath: brandKeyPath]
            }
            if keyPath == modelKeyPath {
                self.model[keyPath: modelKeyPath] = remoteModel[keyPath: modelKeyPath]
            }
            if keyPath == chassisKeyPath {
                self.model[keyPath: chassisKeyPath] = remoteModel[keyPath: chassisKeyPath]
            }
            if keyPath == colorKeyPath {
                self.model[keyPath: colorKeyPath] = remoteModel[keyPath: colorKeyPath]
            }
            if keyPath == escapedKeyPath {
                self.model[keyPath: escapedKeyPath] = remoteModel[keyPath: escapedKeyPath]
            }
            if keyPath == moveConditionKeyPath {
                self.model[keyPath: moveConditionKeyPath] = remoteModel[keyPath: moveConditionKeyPath]
            }
            if keyPath == restrictionKeyPath {
                self.model[keyPath: restrictionKeyPath] = remoteModel[keyPath: restrictionKeyPath]
            }
            if keyPath == noteKeyPath {
                self.model[keyPath: noteKeyPath] = remoteModel[keyPath: noteKeyPath]
            }
        }
        return self.model
    }

    override func didSave() {
        if form.formBuilder.isMerging {
            let mergeResult = form.formBuilder.getConflictsMerging()
            let pendingConflicts = mergeResult.filter { $0.value == nil }
            if !pendingConflicts.isEmpty {
                showPendingConflictsAlert()
            } else {
                self.model = self.getResolvedModel()
                updateOccurrence()
            }
        } else {
            self.model.vehicles = naturesField.selectedNatures.map { nature in
                IdVersion(id: nature.id, version: nature.version)
            }
            self.updateOccurrence()
        }
    }
}
