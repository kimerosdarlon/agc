//
//  DrugUpdateViewController.swift
//  CAD
//
//  Created by Samir Chaves on 27/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class DrugUpdateViewController: OccurrenceUpdateViewController<DrugUpdate> {

    internal var form: DrugForm!
    internal var naturesField: OccurrenceNaturesUpdate<Drug>!
    private let agencyId: String
    private let occurrenceId: UUID
    private let teamId: UUID
    private let drugWithNatures: OccurrenceNatures<Drug>
    private var galleryField: GalleryField!

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    init(occurrenceId: UUID,
         occurrenceNatures: [Nature],
         agencyId: String,
         teamId: UUID,
         drugWithNatures: OccurrenceNatures<Drug>) {
        self.drugWithNatures = drugWithNatures
        self.occurrenceId = occurrenceId
        self.teamId = teamId
        self.agencyId = agencyId

        let drug = drugWithNatures.component
        let drugUpdate = drug.toUpdate(
            teamId: teamId,
            idsVersions: drugWithNatures.objects.map { drug in
                IdVersion(id: drug.id, version: drug.version)
            }
        )

        super.init(model: drugUpdate, name: "Droga", version: drug.version, canDelete: true)

        self.galleryField = GalleryField(label: "Anexos", entityId: drug.externalId ?? drug.id, parentViewController: self)
        self.form = DrugForm(drugUpdate: drugUpdate, parentViewController: self)

        naturesField = OccurrenceNaturesUpdate(
            occurrenceId: occurrenceId,
            occurrenceNatures: occurrenceNatures,
            agencyId: agencyId,
            teamId: teamId,
            object: drugWithNatures,
            parentViewController: self
        )

        form.formBuilder.listenForChanges {
            self.model = self.form.formBuilder.model

            if self.form.formBuilder.isMerging {
                guard let currentVersion = self.remoteModel?.drugs.first?.version else { return }
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
        let drug = DrugDelete(externalId: drugWithNatures.component.externalId, teamId: teamId, drugs: idsVersions)
        startLoading()
        occurrenceService.delete(occurrenceId: occurrenceId, drug: drug) { error in
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

    private func getConflictingFields() -> [PartialKeyPath<DrugUpdate>: String?] {
        guard let remoteDrug = self.remoteModel else { return [:] }
        let initialDrug = self.initialModel
        let drug = self.model
        var conflictingFields = [PartialKeyPath<DrugUpdate>: String?]()

        if initialDrug.apparentType != drug.apparentType &&
            initialDrug.apparentType != remoteDrug.apparentType &&
            drug.apparentType != remoteDrug.apparentType {
            conflictingFields[\DrugUpdate.apparentType] = remoteDrug.apparentType.flatMap { option in
                form.dataSource.domainData?.apparentTypes.first(where: { $0.option == option })?.label
            }
        }
        if initialDrug.package != drug.package &&
            initialDrug.package != remoteDrug.package &&
            drug.package != remoteDrug.package {
            conflictingFields[\DrugUpdate.package] = remoteDrug.package.flatMap { option in
                form.dataSource.domainData?.packaging.first(where: { $0.option == option })?.label
            }
        }
        if initialDrug.measureUnit != drug.measureUnit &&
            initialDrug.measureUnit != remoteDrug.measureUnit &&
            drug.measureUnit != remoteDrug.measureUnit {
            conflictingFields[\DrugUpdate.measureUnit] = remoteDrug.measureUnit.flatMap { option in
                form.dataSource.domainData?.unitiesOfMeasure.first(where: { $0.option == option })?.label
            }
        }
        if initialDrug.quantity != drug.quantity &&
            initialDrug.quantity != remoteDrug.quantity &&
            drug.quantity != remoteDrug.quantity {
            conflictingFields[\DrugUpdate.quantity] = remoteDrug.quantity
        }
        if initialDrug.destination != drug.destination &&
            initialDrug.destination != remoteDrug.destination &&
            drug.destination != remoteDrug.destination {
            conflictingFields[\DrugUpdate.destination] = remoteDrug.destination.flatMap { option in
                form.dataSource.domainData?.destinations.first(where: { $0.option == option })?.label
            }
        }
        if initialDrug.bondWithInvolved != drug.bondWithInvolved &&
            initialDrug.bondWithInvolved != remoteDrug.bondWithInvolved &&
            drug.bondWithInvolved != remoteDrug.bondWithInvolved {
            conflictingFields[\DrugUpdate.bondWithInvolved] = remoteDrug.bondWithInvolved.flatMap { option in
                form.dataSource.domainData?.involvedLinks.first(where: { $0.option == option })?.label
            }
        }
        if initialDrug.note != drug.note &&
            initialDrug.note != remoteDrug.note &&
            drug.note != remoteDrug.note {
            conflictingFields[\DrugUpdate.note] = remoteDrug.note
        }

        return conflictingFields
    }

    override func setupConflictingState() {
        guard let remoteVersion = remoteModel?.drugs.first?.version else { return }
        let conflictingFields = self.getConflictingFields()
        form.formBuilder.setConflictsTo(fieldsKeys: conflictingFields, version: remoteVersion)
    }

    private func doubleCheckConflict() {
        self.occurrenceService.getOccurrenceById(self.occurrenceId) { result in
            garanteeMainThread {
                self.stopLoading()
                switch result {
                case .success(let details):
                    let currentDrugId = self.model.externalId ?? self.drugWithNatures.component.id
                    let drug = details.drugs
                        .first(where: { drug in
                            let drugId = drug.component.externalId ?? drug.component.id
                            return drugId == currentDrugId
                        })
                    self.remoteModel = drug?.component
                        .toUpdate(teamId: self.teamId, idsVersions: drug?.objects.map {
                            IdVersion(id: $0.id, version: $0.version)
                        } ?? [])

                    self.model.drugs = self.remoteModel?.drugs ?? []
                    let conflictingFields = self.getConflictingFields()
                    if !conflictingFields.isEmpty {
                        self.showConflictAlert()
                    } else {
                        self.model.drugs = self.remoteModel!.drugs
                        self.updateOccurrence()
                    }
                case .failure(let error as NSError):
                    self.showErrorAlert(title: "Erro durando a atualização", message: error.domain)
                }
            }
        }
    }

    private func updateOccurrence() {
        startLoading()
        occurrenceService.update(occurrenceId: occurrenceId, drug: self.model) { error in
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

    func getResolvedModel() -> DrugUpdate {
        guard let remoteModel = self.remoteModel else { return self.model }
        let mergeResult = form.formBuilder.getConflictsMerging()
        let resolvedMerge = mergeResult.filter { $0.value != nil } as! [PartialKeyPath<DrugUpdate>: FieldConflictMergeStrategy]
        let fieldsResolvedAsTheirs = resolvedMerge.filter { $0.value == .theirs }.map { $0.key }

        let apparentTypeKeyPath = form.formBuilder.extractWritableKey(keyPath: \.apparentType)
        let packageKeyPath = form.formBuilder.extractWritableKey(keyPath: \.package)
        let measureUnitKeyPath = form.formBuilder.extractWritableKey(keyPath: \.measureUnit)
        let quantityKeyPath = form.formBuilder.extractWritableKey(keyPath: \.quantity)
        let destinationKeyPath = form.formBuilder.extractWritableKey(keyPath: \.destination)
        let bondWithInvolvedKeyPath = form.formBuilder.extractWritableKey(keyPath: \.bondWithInvolved)
        let noteKeyPath = form.formBuilder.extractWritableKey(keyPath: \.note)

        fieldsResolvedAsTheirs.forEach { keyPath in
            if keyPath == apparentTypeKeyPath {
                self.model[keyPath: apparentTypeKeyPath] = remoteModel[keyPath: apparentTypeKeyPath]
            }
            if keyPath == packageKeyPath {
                self.model[keyPath: packageKeyPath] = remoteModel[keyPath: packageKeyPath]
            }
            if keyPath == measureUnitKeyPath {
                self.model[keyPath: measureUnitKeyPath] = remoteModel[keyPath: measureUnitKeyPath]
            }
            if keyPath == quantityKeyPath {
                self.model[keyPath: quantityKeyPath] = remoteModel[keyPath: quantityKeyPath]
            }
            if keyPath == destinationKeyPath {
                self.model[keyPath: destinationKeyPath] = remoteModel[keyPath: destinationKeyPath]
            }
            if keyPath == bondWithInvolvedKeyPath {
                self.model[keyPath: bondWithInvolvedKeyPath] = remoteModel[keyPath: bondWithInvolvedKeyPath]
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
            self.model.drugs = naturesField.selectedNatures.map { nature in
                IdVersion(id: nature.id, version: nature.version)
            }
            self.updateOccurrence()
        }
    }
}
