//
//  OccurrenceWeaponsViewController.swift
//  CAD
//
//  Created by Samir Chaves on 22/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class OccurrenceWeaponsViewController: ObjectDetailsViewController {

    init(with occurrence: OccurrenceDetails) {
        super.init(with: occurrence,
                   emptyFeedback: "Nenhuma arma presente nesta ocorrência")
        title = "Armas"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func formatDate(_ dateOpt: Date?) -> String {
        if let date = dateOpt {
            return dateFormatter.string(from: date)
        }

        return "————"
    }

    private func getDetailsBlock(weaponWithNatures: OccurrenceNatures<Weapon>) -> DetailsBlock {
        let weapon = weaponWithNatures.component
        let items = [
            [(title: "Marca", detail: fillBlankField(weapon.brand)), (title: "Modelo", detail: fillBlankField(weapon.model))],
            [(title: "Calibre", detail: fillBlankField(weapon.caliber)), (title: "Espécie", detail: fillBlankField(weapon.specie))],
            [(title: "N° Identificação", detail: fillBlankField(weapon.serialNumber)), (title: "N° Sinarm", detail: fillBlankField(weapon.sinarmSigmaNumber))],
            [(title: "Destinação", detail: fillBlankField(weapon.destination)), (title: "Fabricação", detail: fillBlankField(weapon.manufacture))],
            [(title: "Vínculo com o Envolvido", detail: fillBlankField(weapon.bondWithInvolved))],
            [(title: "Observações", detail: fillBlankField(weapon.note))]
        ]
        let weaponType = weapon.type ?? "Tipo não informado"
        var detailsGroup = DetailsGroup(items: items, withTitle: weaponType)

        if self.canEdit {
            let editButton = buildEditButton()
            editButton.addAction {
                guard let activeTeamId = self.cadService.getActiveTeam()?.id else { return }
                let weaponUpdate = WeaponUpdateViewController(
                    occurrenceId: self.detail.occurrenceId,
                    occurrenceNatures: self.detail.natures,
                    agencyId: self.detail.operatingRegion.agency.id,
                    teamId: activeTeamId,
                    weaponWithNatures: weaponWithNatures
                )
                weaponUpdate.updateDelegate = self.updateDelegate
                self.navigationController?.pushViewController(weaponUpdate, animated: true)
            }
            detailsGroup = DetailsGroup(items: items, withTitle: weaponType, withExtra: editButton)
        }

        let natures = weaponWithNatures.objects.map { object in
            object.situation.map { "\(object.nature) | \($0)" } ?? object.nature
        }
        detailsGroup.addTagItem((title: "Naturezas", tags: natures))
        
        return DetailsBlock(groups: [detailsGroup], identifier: (weapon.externalId ?? weapon.id).uuidString)
    }

    override func isEmpty() -> Bool {
        detail.weapons.isEmpty
    }

    override func getDetailsBlocks() -> [DetailsBlock] {
        return detail.weapons.map {
            self.getDetailsBlock(weaponWithNatures: $0)
        }
    }

    override func didAddObject() {
        guard let activeTeamId = cadService.getActiveTeam()?.id else { return }
        let weaponInsert = WeaponInsertViewController(
            occurrenceId: detail.occurrenceId,
            occurrenceNatures: detail.natures,
            agencyId: detail.operatingRegion.agency.id,
            teamId: activeTeamId
        )
        weaponInsert.updateDelegate = updateDelegate
        self.navigationController?.pushViewController(weaponInsert, animated: true)
    }
}
