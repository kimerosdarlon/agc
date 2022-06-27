//
//  OccurrenceVehiclesDetailViewController.swift
//  CAD
//
//  Created by Samir Chaves on 22/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class OccurrenceVehiclesDetailViewController: ObjectDetailsViewController {
    init(with occurrence: OccurrenceDetails) {
        super.init(with: occurrence,
                   emptyFeedback: "Nenhum veículo presente nesta ocorrência")
        title = "Veículos"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getDetailsBlock(vehicleWithNatures: OccurrenceNatures<Vehicle>) -> DetailsBlock {
        let vehicle = vehicleWithNatures.component
        let plate: String? = vehicle.plate.map { plate in
            var mutablePlate = "\(plate.replacingOccurrences(of: "-", with: ""))"
            mutablePlate.insert("-", at: mutablePlate.index(mutablePlate.startIndex, offsetBy: 3))
            return mutablePlate.uppercased()
        } ?? "Placa não informada"

        var items: [[InteractableDetailItem]] = InteractableDetailItem.noInteraction([
            [(title: "Marca", detail: fillBlankField(vehicle.brand)), (title: "Modelo", detail: fillBlankField(vehicle.model))],
            [(title: "Chassi", detail: fillBlankField(vehicle.chassis)), (title: "Cor", detail: fillBlankField(vehicle.color))],
            [(title: "Condições de Deslocamento", detail: fillBlankField(vehicle.moveCondition)), (title: "Roubo ou Furto", detail: fillBlankField(vehicle.robberyTheft))],
            [(title: "Tipo", detail: fillBlankField(vehicle.type)), (title: "Vínculo com o Envolvido", detail: fillBlankField(vehicle.bondWithInvolved))],
            [(title: "Escapou", detail: fillBlankField(vehicle.escaped)), (title: "Restrição", detail: fillBlankField(vehicle.restriction))],
            [(title: "Características", detail: fillBlankField(vehicle.characteristics))],
            [(title: "Observações", detail: fillBlankField(vehicle.note))]
        ])
        let natures = vehicleWithNatures.objects.map { object in
            object.situation.map { "\(object.nature) | \($0)" } ?? object.nature
        }
        items.append([
            InteractableDetailItem(fromItem: (title: "Naturezas", tags: natures))
        ])

        var detailsGroup = DetailsGroup(items: items, withTitle: plate, titleHasInteraction: true)
        if let involvement = vehicle.involvement {
            detailsGroup = DetailsGroup(items: items, withTitle: plate, withTags: [involvement], titleHasInteraction: true)
        }

        if self.canEdit {
            let editButton = buildEditButton()
            editButton.addAction {
                guard let activeTeamId = self.cadService.getActiveTeam()?.id else { return }
                let vehicleUpdate = VehicleUpdateViewController(
                    occurrenceId: self.detail.occurrenceId,
                    occurrenceNatures: self.detail.natures,
                    agencyId: self.detail.operatingRegion.agency.id,
                    teamId: activeTeamId,
                    vehicleWithNatures: vehicleWithNatures
                )
                vehicleUpdate.updateDelegate = self.updateDelegate
                self.navigationController?.pushViewController(vehicleUpdate, animated: true)
            }
            detailsGroup = DetailsGroup(items: items, withTitle: plate, withExtra: editButton, titleHasInteraction: true)
        }

        return DetailsBlock(group: detailsGroup, identifier: (vehicle.externalID ?? vehicle.id).uuidString)
    }

    override func getDetailsBlocks() -> [DetailsBlock] {
        return detail.vehicles.map {
            self.getDetailsBlock(vehicleWithNatures: $0)
        }
    }

    override func isEmpty() -> Bool {
        detail.vehicles.isEmpty
    }

    override func didAddObject() {
        guard let activeTeamId = cadService.getActiveTeam()?.id else { return }
        let vehicleInsert = VehicleInsertViewController(
            occurrenceId: detail.occurrenceId,
            occurrenceNatures: detail.natures,
            agencyId: detail.operatingRegion.agency.id,
            teamId: activeTeamId
        )
        vehicleInsert.updateDelegate = updateDelegate
        self.navigationController?.pushViewController(vehicleInsert, animated: true)
    }
}
