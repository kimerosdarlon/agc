//
//  InvolvedUpdateViewController.swift
//  CAD
//
//  Created by Samir Chaves on 27/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class InvolvedUpdateViewController: OccurrenceUpdateViewController<InvolvedUpdate> {

    internal var form: InvolvedForm!
    internal var naturesField: OccurrenceNaturesUpdate<Involved>!
    private let agencyId: String
    private let occurrenceId: UUID
    private let teamId: UUID
    private let involvedWithNatures: OccurrenceNatures<Involved>
    private var galleryField: GalleryField!

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    init(occurrenceId: UUID,
         occurrenceNatures: [Nature],
         agencyId: String,
         teamId: UUID,
         involvedWithNatures: OccurrenceNatures<Involved>) {
        self.involvedWithNatures = involvedWithNatures
        self.occurrenceId = occurrenceId
        self.teamId = teamId
        self.agencyId = agencyId

        let involved = involvedWithNatures.component
        let involvedUpdate = involved.toUpdate(
            teamId: teamId,
            idsVersions: involvedWithNatures.objects.map { involved in
                IdVersion(id: involved.id, version: involved.version)
            }
        )

        super.init(model: involvedUpdate, name: "Envolvido", version: involved.version, canDelete: true)

        self.galleryField = GalleryField(label: "Anexos", entityId: involved.externalId ?? involved.id, parentViewController: self)
        self.form = InvolvedForm(involvedUpdate: involvedUpdate, parentViewController: self)

        naturesField = OccurrenceNaturesUpdate(
            occurrenceId: occurrenceId,
            occurrenceNatures: occurrenceNatures,
            agencyId: agencyId,
            teamId: teamId,
            object: involvedWithNatures,
            parentViewController: self
        )


        form.formBuilder.listenForChanges {
            self.model = self.form.formBuilder.model

            if self.form.formBuilder.isMerging {
                guard let currentVersion = self.remoteModel?.involved.first?.version else { return }
                let conflictingFields = self.getConflictingFields()
                self.form.formBuilder.setConflictsTo(fieldsKeys: conflictingFields, version: currentVersion)
            }
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

    override func didRemoveItem() {
        let idsVersions = naturesField.selectedNatures.map { IdVersion(id: $0.id, version: $0.version) }
        let involved = InvolvedDelete(externalId: involvedWithNatures.component.externalId, teamId: teamId, involved: idsVersions)
        startLoading()
        occurrenceService.delete(occurrenceId: occurrenceId, involved: involved) { error in
            garanteeMainThread {
                self.stopLoading()
                if let error = error as NSError? {
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

    private func getConflictingFields() -> [PartialKeyPath<InvolvedUpdate>: String?] {
        guard let remoteInvolved = self.remoteModel else { return [:] }
        let initialInvolved = self.initialModel
        let involved = self.model
        var conflictingFields = [PartialKeyPath<InvolvedUpdate>: String?]()

        if initialInvolved.name != involved.name &&
            initialInvolved.name != remoteInvolved.name &&
            involved.name != remoteInvolved.name {
            conflictingFields[\InvolvedUpdate.name] = remoteInvolved.name
        }
        if initialInvolved.gender != involved.gender &&
            initialInvolved.gender != remoteInvolved.gender &&
            involved.gender != remoteInvolved.gender {
            conflictingFields[\InvolvedUpdate.gender] = remoteInvolved.gender.flatMap { option in
                form.dataSource.domainData?.sexes.first(where: { $0.option == option })?.label
            }
        }
        if initialInvolved.colorRace != involved.colorRace &&
            initialInvolved.colorRace != remoteInvolved.colorRace &&
            involved.colorRace != remoteInvolved.colorRace {
            conflictingFields[\InvolvedUpdate.colorRace] = remoteInvolved.colorRace.flatMap { option in
                form.dataSource.domainData?.races.first(where: { $0.option == option })?.label
            }
        }
        if initialInvolved.motherName != involved.motherName &&
            initialInvolved.motherName != remoteInvolved.motherName &&
            involved.motherName != remoteInvolved.motherName {
            conflictingFields[\InvolvedUpdate.motherName] = remoteInvolved.motherName
        }
        if initialInvolved.birthDate != involved.birthDate &&
            initialInvolved.birthDate != remoteInvolved.birthDate &&
            involved.birthDate != remoteInvolved.birthDate {
            conflictingFields[\InvolvedUpdate.birthDate] = remoteInvolved.birthDate
        }
        if initialInvolved.documentType != involved.documentType &&
            initialInvolved.documentType != remoteInvolved.documentType &&
            involved.documentType != remoteInvolved.documentType {
            conflictingFields[\InvolvedUpdate.documentType] = remoteInvolved.documentType.flatMap { option in
                form.dataSource.domainData?.documentTypes.first(where: { $0.option == option })?.label
            }
        }
        if initialInvolved.documentNumber != involved.documentNumber &&
            initialInvolved.documentNumber != remoteInvolved.documentNumber &&
            involved.documentNumber != remoteInvolved.documentNumber {
            conflictingFields[\InvolvedUpdate.documentNumber] = remoteInvolved.documentNumber
        }
        if initialInvolved.warrantNumber != involved.warrantNumber &&
            initialInvolved.warrantNumber != remoteInvolved.warrantNumber &&
            involved.warrantNumber != remoteInvolved.warrantNumber {
            conflictingFields[\InvolvedUpdate.warrantNumber] = remoteInvolved.warrantNumber
        }
        if initialInvolved.organInitials != involved.organInitials &&
            initialInvolved.organInitials != remoteInvolved.organInitials &&
            involved.organInitials != remoteInvolved.organInitials {
            conflictingFields[\InvolvedUpdate.organInitials] = remoteInvolved.organInitials
        }

        return conflictingFields
    }

    override func setupConflictingState() {
        guard let remoteVersion = remoteModel?.involved.first?.version else { return }
        let conflictingFields = self.getConflictingFields()
        form.formBuilder.setConflictsTo(fieldsKeys: conflictingFields, version: remoteVersion)
    }

    private func doubleCheckConflict() {
        self.occurrenceService.getOccurrenceById(self.occurrenceId) { result in
            garanteeMainThread {
                self.stopLoading()
                switch result {
                case .success(let details):
                    let currentInvolvedId = self.model.externalId ?? self.involvedWithNatures.component.id
                    let involved = details.involved
                        .first(where: { involved in
                            let involvedId = involved.component.externalId ?? involved.component.id
                            return involvedId == currentInvolvedId
                        })
                    self.remoteModel = involved?.component
                        .toUpdate(teamId: self.teamId, idsVersions: involved?.objects.map {
                            IdVersion(id: $0.id, version: $0.version)
                        } ?? [])

                    self.model.involved = self.remoteModel?.involved ?? []
                    let conflictingFields = self.getConflictingFields()
                    if !conflictingFields.isEmpty {
                        self.showConflictAlert()
                    } else {
                        self.model.involved = self.remoteModel!.involved
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
        occurrenceService.update(occurrenceId: occurrenceId, involved: self.model) { error in
            garanteeMainThread {
                if let error = error as NSError? {
                    if self.isUnauthorized(error) {
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

    func getResolvedModel() -> InvolvedUpdate {
        guard let remoteModel = self.remoteModel else { return self.model }
        let mergeResult = form.formBuilder.getConflictsMerging()
        let resolvedMerge = mergeResult.filter { $0.value != nil } as! [PartialKeyPath<InvolvedUpdate>: FieldConflictMergeStrategy]
        let fieldsResolvedAsTheirs = resolvedMerge.filter { $0.value == .theirs }.map { $0.key }

        let nameKeyPath = form.formBuilder.extractWritableKey(keyPath: \.name)
        let genderKeyPath = form.formBuilder.extractWritableKey(keyPath: \.gender)
        let colorRaceKeyPath = form.formBuilder.extractWritableKey(keyPath: \.colorRace)
        let motherNameKeyPath = form.formBuilder.extractWritableKey(keyPath: \.motherName)
        let birthDateKeyPath = form.formBuilder.extractWritableKey(keyPath: \.birthDate)
        let documentTypeKeyPath = form.formBuilder.extractWritableKey(keyPath: \.documentType)
        let documentNumberKeyPath = form.formBuilder.extractWritableKey(keyPath: \.documentNumber)
        let warrantNumberKeyPath = form.formBuilder.extractWritableKey(keyPath: \.warrantNumber)
        let organInitialsKeyPath = form.formBuilder.extractWritableKey(keyPath: \.organInitials)

        fieldsResolvedAsTheirs.forEach { keyPath in
            if keyPath == nameKeyPath {
                self.model[keyPath: nameKeyPath] = remoteModel[keyPath: nameKeyPath]
            }
            if keyPath == genderKeyPath {
                self.model[keyPath: genderKeyPath] = remoteModel[keyPath: genderKeyPath]
            }
            if keyPath == colorRaceKeyPath {
                self.model[keyPath: colorRaceKeyPath] = remoteModel[keyPath: colorRaceKeyPath]
            }
            if keyPath == motherNameKeyPath {
                self.model[keyPath: motherNameKeyPath] = remoteModel[keyPath: motherNameKeyPath]
            }
            if keyPath == birthDateKeyPath {
                self.model[keyPath: birthDateKeyPath] = remoteModel[keyPath: birthDateKeyPath]
            }
            if keyPath == documentTypeKeyPath {
                self.model[keyPath: documentTypeKeyPath] = remoteModel[keyPath: documentTypeKeyPath]
            }
            if keyPath == documentNumberKeyPath {
                self.model[keyPath: documentNumberKeyPath] = remoteModel[keyPath: documentNumberKeyPath]
            }
            if keyPath == warrantNumberKeyPath {
                self.model[keyPath: warrantNumberKeyPath] = remoteModel[keyPath: warrantNumberKeyPath]
            }
            if keyPath == organInitialsKeyPath {
                self.model[keyPath: organInitialsKeyPath] = remoteModel[keyPath: organInitialsKeyPath]
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
            self.model.involved = naturesField.selectedNatures.map { nature in
                IdVersion(id: nature.id, version: nature.version)
            }
            self.updateOccurrence()
        }
    }
}
