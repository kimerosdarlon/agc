//
//  OccurrenceInvolvedViewController.swift
//  CAD
//
//  Created by Samir Chaves on 22/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class OccurrenceInvolvedViewController: ObjectDetailsViewController {

    init(with occurrence: OccurrenceDetails) {
        super.init(with: occurrence,
                   emptyFeedback: "Nenhum envolvido presente nesta ocorrência")
        title = "Envolvidos"
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

    private func formatDate(_ dateOpt: Date?) -> String {
        if let date = dateOpt {
            return dateFormatter.string(from: date)
        }

        return String.emptyProperty
    }

    private func getDetailsBlock(involvedWithNatures: OccurrenceNatures<Involved>) -> DetailsBlock {
        let involved = involvedWithNatures.component
        let birthDate = involved.birthDate?.toDate(format: "yyyy-MM-dd")
        let age = birthDate?.difference(to: Date(), [.year]).year
        var ageString = String.emptyProperty
        if let age = age, let birthDate = birthDate {
            ageString = "\(birthDate.format(to: "dd/MM/yyyy")) | \(age) anos"
        }
        var items: [[InteractableDetailItem]] = InteractableDetailItem.noInteraction([
            [(title: "Gênero", detail: fillBlankField(involved.gender)), (title: "Raça", detail: fillBlankField(involved.colorRace))]
        ])

        items.append([
            InteractableDetailItem(fromItem: (title: "Nome da Mãe", detail: fillBlankField(involved.motherName)), hasInteraction: involved.motherName != nil, hasMapInteraction: false),
            InteractableDetailItem(fromItem: (title: "Idade", detail: ageString), hasInteraction: false)
        ])

        items.append(contentsOf: InteractableDetailItem.noInteraction([
            [(title: involved.documentType ?? "Documento", detail: fillBlankField(involved.documentNumber))],
            [(title: "Número do Mandado", detail: fillBlankField(involved.warrantNumber)), (title: "Órgão Responsável", detail: fillBlankField(involved.organInitials))],
            [(title: "Observações", detail: fillBlankField(involved.note))]
        ]))

        let involvedName = involved.name ?? "Nome não informado"
        var detailsGroup = DetailsGroup(items: items, withTitle: involvedName, titleHasInteraction: true)

        if self.canEdit {
            let editButton = buildEditButton()
            editButton.addAction {
                guard let activeTeamId = self.cadService.getActiveTeam()?.id else { return }
                let involvedUpdate = InvolvedUpdateViewController(
                    occurrenceId: self.detail.occurrenceId,
                    occurrenceNatures: self.detail.natures,
                    agencyId: self.detail.operatingRegion.agency.id,
                    teamId: activeTeamId,
                    involvedWithNatures: involvedWithNatures
                )
                involvedUpdate.updateDelegate = self.updateDelegate
                self.navigationController?.pushViewController(involvedUpdate, animated: true)
            }
            detailsGroup = DetailsGroup(items: items, withTitle: involvedName, withExtra: editButton, titleHasInteraction: true)
        }
        let natures = involvedWithNatures.objects.map { object in
            object.situation.map { "\(object.nature) | \($0)" } ?? object.nature
        }
        detailsGroup.addTagItem((title: "Naturezas", tags: natures))

        return DetailsBlock(groups: [detailsGroup], identifier: (involved.externalId ?? involved.id).uuidString)
    }

    override func isEmpty() -> Bool {
        detail.involved.isEmpty
    }

    override func didAddObject() {
        guard let activeTeamId = cadService.getActiveTeam()?.id else { return }
        let involvedInsert = InvolvedInsertViewController(
            occurrenceId: detail.occurrenceId,
            occurrenceNatures: detail.natures,
            agencyId: detail.operatingRegion.agency.id,
            teamId: activeTeamId
        )
        involvedInsert.updateDelegate = updateDelegate
        self.navigationController?.pushViewController(involvedInsert, animated: true)
    }

    override func getDetailsBlocks() -> [DetailsBlock] {
        return detail.involved.map {
            self.getDetailsBlock(involvedWithNatures: $0)
        }
    }
}
