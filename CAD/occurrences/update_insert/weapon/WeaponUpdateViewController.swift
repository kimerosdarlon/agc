//
//  WeaponUpdateViewController.swift
//  CAD
//
//  Created by Samir Chaves on 28/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class WeaponUpdateViewController: OccurrenceUpdateViewController<WeaponUpdate> {

    internal var form: WeaponForm!
    internal var naturesField: OccurrenceNaturesUpdate<Weapon>!
    private let agencyId: String
    private let occurrenceId: UUID
    private let teamId: UUID
    private let weaponWithNatures: OccurrenceNatures<Weapon>
    private var galleryField: GalleryField!

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    init(occurrenceId: UUID,
         occurrenceNatures: [Nature],
         agencyId: String,
         teamId: UUID,
         weaponWithNatures: OccurrenceNatures<Weapon>) {
        self.weaponWithNatures = weaponWithNatures
        self.occurrenceId = occurrenceId
        self.teamId = teamId
        self.agencyId = agencyId

        let weapon = weaponWithNatures.component
        let weaponUpdate = weapon.toUpdate(
            teamId: teamId,
            idsVersions: weaponWithNatures.objects.map { weapon in
                IdVersion(id: weapon.id, version: weapon.version)
            }
        )

        super.init(model: weaponUpdate, name: "Arma", version: weapon.version, canDelete: true)

        self.galleryField = GalleryField(label: "Anexos", entityId: weapon.externalId ?? weapon.id, parentViewController: self)
        self.form = WeaponForm(weaponUpdate: weaponUpdate, parentViewController: self)

        naturesField = OccurrenceNaturesUpdate(
            occurrenceId: occurrenceId,
            occurrenceNatures: occurrenceNatures,
            agencyId: agencyId,
            teamId: teamId,
            object: weaponWithNatures,
            parentViewController: self
        )

        form.formBuilder.listenForChanges {
            self.model = self.form.formBuilder.model

            if self.form.formBuilder.isMerging {
                guard let currentVersion = self.remoteModel?.weapons.first?.version else { return }
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
        let weapon = WeaponDelete(externalId: weaponWithNatures.component.externalId, teamId: teamId, weapons: idsVersions)
        startLoading()
        occurrenceService.delete(occurrenceId: occurrenceId, weapon: weapon) { error in
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

    private func getConflictingFields() -> [PartialKeyPath<WeaponUpdate>: String?] {
        guard let remoteWeapon = self.remoteModel else { return [:] }
        let initialWeapon = self.initialModel
        let weapon = self.model
        var conflictingFields = [PartialKeyPath<WeaponUpdate>: String?]()

        if initialWeapon.type != weapon.type &&
            initialWeapon.type != remoteWeapon.type &&
            weapon.type != remoteWeapon.type {
            conflictingFields[\WeaponUpdate.type] = remoteWeapon.type.flatMap { option in
                form.dataSource.domainData?.types.first(where: { $0.option == option })?.label
            }
        }
        if initialWeapon.specie != weapon.specie &&
            initialWeapon.specie != remoteWeapon.specie &&
            weapon.specie != remoteWeapon.specie {
            conflictingFields[\WeaponUpdate.specie] = remoteWeapon.specie.flatMap { option in
                form.dataSource.domainData?.species.first(where: { $0.option == option })?.label
            }
        }
        if initialWeapon.brand != weapon.brand &&
            initialWeapon.brand != remoteWeapon.brand &&
            weapon.brand != remoteWeapon.brand {
            conflictingFields[\WeaponUpdate.brand] = remoteWeapon.brand.flatMap { option in
                form.dataSource.domainData?.brands.first(where: { $0.option == option })?.label
            }
        }
        if initialWeapon.model != weapon.model &&
            initialWeapon.model != remoteWeapon.model &&
            weapon.model != remoteWeapon.model {
            conflictingFields[\WeaponUpdate.model] = remoteWeapon.model.flatMap { option in
                form.dataSource.domainData?.models.first(where: { $0.option == option })?.label
            }
        }
        if initialWeapon.caliber != weapon.caliber &&
            initialWeapon.caliber != remoteWeapon.caliber &&
            weapon.caliber != remoteWeapon.caliber {
            conflictingFields[\WeaponUpdate.caliber] = remoteWeapon.caliber.flatMap { option in
                form.dataSource.domainData?.calibers.first(where: { $0.option == option })?.label
            }
        }
        if initialWeapon.serialNumber != weapon.serialNumber &&
            initialWeapon.serialNumber != remoteWeapon.serialNumber &&
            weapon.serialNumber != remoteWeapon.serialNumber {
            conflictingFields[\WeaponUpdate.serialNumber] = remoteWeapon.serialNumber
        }
        if initialWeapon.sinarmSigmaNumber != weapon.sinarmSigmaNumber &&
            initialWeapon.sinarmSigmaNumber != remoteWeapon.sinarmSigmaNumber &&
            weapon.sinarmSigmaNumber != remoteWeapon.sinarmSigmaNumber {
            conflictingFields[\WeaponUpdate.sinarmSigmaNumber] = remoteWeapon.sinarmSigmaNumber
        }
        if initialWeapon.destination != weapon.destination &&
            initialWeapon.destination != remoteWeapon.destination &&
            weapon.destination != remoteWeapon.destination {
            conflictingFields[\WeaponUpdate.destination] = remoteWeapon.destination.flatMap { option in
                form.dataSource.domainData?.destinations.first(where: { $0.option == option })?.label
            }
        }
        if initialWeapon.manufacture != weapon.manufacture &&
            initialWeapon.manufacture != remoteWeapon.manufacture &&
            weapon.manufacture != remoteWeapon.manufacture {
            conflictingFields[\WeaponUpdate.manufacture] = remoteWeapon.manufacture.flatMap { option in
                form.dataSource.domainData?.manufactures.first(where: { $0.option == option })?.label
            }
        }
        if initialWeapon.bondWithInvolved != weapon.bondWithInvolved &&
            initialWeapon.bondWithInvolved != remoteWeapon.bondWithInvolved &&
            weapon.bondWithInvolved != remoteWeapon.bondWithInvolved {
            conflictingFields[\WeaponUpdate.bondWithInvolved] = remoteWeapon.bondWithInvolved.flatMap { option in
                form.dataSource.domainData?.involvedLinks.first(where: { $0.option == option })?.label
            }
        }
        if initialWeapon.note != weapon.note &&
            initialWeapon.note != remoteWeapon.note &&
            weapon.note != remoteWeapon.note {
            conflictingFields[\WeaponUpdate.note] = remoteWeapon.note
        }

        return conflictingFields
    }

    override func setupConflictingState() {
        guard let remoteVersion = remoteModel?.weapons.first?.version else { return }
        let conflictingFields = self.getConflictingFields()
        form.formBuilder.setConflictsTo(fieldsKeys: conflictingFields, version: remoteVersion)
    }

    private func doubleCheckConflict() {
        self.occurrenceService.getOccurrenceById(self.occurrenceId) { result in
            garanteeMainThread {
                self.stopLoading()
                switch result {
                case .success(let details):
                    let currentWeaponId = self.model.externalId ?? self.weaponWithNatures.component.id
                    let weapon = details.weapons
                        .first(where: { weapon in
                            let weaponId = weapon.component.externalId ?? weapon.component.id
                            return weaponId == currentWeaponId
                        })
                    self.remoteModel = weapon?.component
                        .toUpdate(teamId: self.teamId, idsVersions: weapon?.objects.map {
                            IdVersion(id: $0.id, version: $0.version)
                        } ?? [])

                    self.model.weapons = self.remoteModel?.weapons ?? []
                    let conflictingFields = self.getConflictingFields()
                    if !conflictingFields.isEmpty {
                        self.showConflictAlert()
                    } else {
                        self.model.weapons = self.remoteModel!.weapons
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
        occurrenceService.update(occurrenceId: occurrenceId, weapon: self.model) { error in
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

    func getResolvedModel() -> WeaponUpdate {
        guard let remoteModel = self.remoteModel else { return self.model }
        let mergeResult = form.formBuilder.getConflictsMerging()
        let resolvedMerge = mergeResult.filter { $0.value != nil } as! [PartialKeyPath<WeaponUpdate>: FieldConflictMergeStrategy]
        let fieldsResolvedAsTheirs = resolvedMerge.filter { $0.value == .theirs }.map { $0.key }

        let typeKeyPath = form.formBuilder.extractWritableKey(keyPath: \.type)
        let specieKeyPath = form.formBuilder.extractWritableKey(keyPath: \.specie)
        let brandKeyPath = form.formBuilder.extractWritableKey(keyPath: \.brand)
        let modelKeyPath = form.formBuilder.extractWritableKey(keyPath: \.model)
        let caliberKeyPath = form.formBuilder.extractWritableKey(keyPath: \.caliber)
        let serialNumberKeyPath = form.formBuilder.extractWritableKey(keyPath: \.serialNumber)
        let sinarmSigmaNumberKeyPath = form.formBuilder.extractWritableKey(keyPath: \.sinarmSigmaNumber)
        let destinationKeyPath = form.formBuilder.extractWritableKey(keyPath: \.destination)
        let manufactureKeyPath = form.formBuilder.extractWritableKey(keyPath: \.manufacture)
        let bondWithInvolvedKeyPath = form.formBuilder.extractWritableKey(keyPath: \.bondWithInvolved)
        let noteKeyPath = form.formBuilder.extractWritableKey(keyPath: \.note)

        fieldsResolvedAsTheirs.forEach { keyPath in
            if keyPath == typeKeyPath {
                self.model[keyPath: typeKeyPath] = remoteModel[keyPath: typeKeyPath]
            }
            if keyPath == specieKeyPath {
                self.model[keyPath: specieKeyPath] = remoteModel[keyPath: specieKeyPath]
            }
            if keyPath == brandKeyPath {
                self.model[keyPath: brandKeyPath] = remoteModel[keyPath: brandKeyPath]
            }
            if keyPath == modelKeyPath {
                self.model[keyPath: modelKeyPath] = remoteModel[keyPath: modelKeyPath]
            }
            if keyPath == caliberKeyPath {
                self.model[keyPath: caliberKeyPath] = remoteModel[keyPath: caliberKeyPath]
            }
            if keyPath == serialNumberKeyPath {
                self.model[keyPath: serialNumberKeyPath] = remoteModel[keyPath: serialNumberKeyPath]
            }
            if keyPath == sinarmSigmaNumberKeyPath {
                self.model[keyPath: sinarmSigmaNumberKeyPath] = remoteModel[keyPath: sinarmSigmaNumberKeyPath]
            }
            if keyPath == destinationKeyPath {
                self.model[keyPath: destinationKeyPath] = remoteModel[keyPath: destinationKeyPath]
            }
            if keyPath == manufactureKeyPath {
                self.model[keyPath: manufactureKeyPath] = remoteModel[keyPath: manufactureKeyPath]
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
            self.model.weapons = naturesField.selectedNatures.map { nature in
                IdVersion(id: nature.id, version: nature.version)
            }
            self.updateOccurrence()
        }
    }
}
