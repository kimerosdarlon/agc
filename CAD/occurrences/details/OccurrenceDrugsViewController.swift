//
//  OccurrenceDrugsViewController.swift
//  CAD
//
//  Created by Samir Chaves on 01/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class OccurrenceDrugsViewController: ObjectDetailsViewController {

    init(with occurrence: OccurrenceDetails) {
        super.init(with: occurrence,
                   emptyFeedback: "Nenhuma droga presente nesta ocorrência")
        title = "Drogas"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getDetailsBlock(drugWithNatures: OccurrenceNatures<Drug>) -> DetailsBlock {
        let drug = drugWithNatures.component

        var items: [[InteractableDetailItem]] = InteractableDetailItem.noInteraction([
            [(title: "Destinação", detail: fillBlankField(drug.destination)), (title: "Tipo de Embalagem", detail: fillBlankField(drug.package))],
            [(title: "Unidade", detail: fillBlankField(drug.measureUnit)), (title: "Quantidade", detail: fillBlankField(drug.amount))],
            [(title: "Vínculo com o Envolvido", detail: fillBlankField(drug.bondWithInvolved))],
            [(title: "Observações", detail: fillBlankField(drug.note))]
        ])
        let natures = drugWithNatures.objects.map { object in
            object.situation.map { "\(object.nature) | \($0)" } ?? object.nature
        }
        items.append([
            InteractableDetailItem(fromItem: (title: "Naturezas", tags: natures))
        ])
        let drugApparentType = drug.apparentType ?? "Tipo aparente não informado"
        var detailsGroup = DetailsGroup(items: items, withTitle: drugApparentType)

        if self.canEdit {
            let editButton = buildEditButton()
            editButton.addAction {
                guard let activeTeamId = self.cadService.getActiveTeam()?.id else { return }
                let drugUpdate = DrugUpdateViewController(
                    occurrenceId: self.detail.occurrenceId,
                    occurrenceNatures: self.detail.natures,
                    agencyId: self.detail.operatingRegion.agency.id,
                    teamId: activeTeamId,
                    drugWithNatures: drugWithNatures
                )
                drugUpdate.updateDelegate = self.updateDelegate
                self.navigationController?.pushViewController(drugUpdate, animated: true)
            }
            detailsGroup = DetailsGroup(items: items, withTitle: drugApparentType, withExtra: editButton)
        }

        return DetailsBlock(groups: [detailsGroup], identifier: (drug.externalId ?? drug.id).uuidString)
    }

    override func isEmpty() -> Bool {
        detail.drugs.isEmpty
    }

    override func didAddObject() {
        guard let activeTeamId = cadService.getActiveTeam()?.id else { return }
        let drugInsert = DrugInsertViewController(
            occurrenceId: detail.occurrenceId,
            occurrenceNatures: detail.natures,
            agencyId: detail.operatingRegion.agency.id,
            teamId: activeTeamId
        )
        drugInsert.updateDelegate = updateDelegate
        self.navigationController?.pushViewController(drugInsert, animated: true)
    }

    override func getDetailsBlocks() -> [DetailsBlock] {
        return detail.drugs.map {
            self.getDetailsBlock(drugWithNatures: $0)
        }
    }
}
