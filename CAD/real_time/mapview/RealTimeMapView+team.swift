//
//  RealTimeMapView+team.swift
//  CAD
//
//  Created by Samir Chaves on 07/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import MapKit

// Managing team user position
extension RealTimeMapView {
    private func createPin<U: TeamMemberAnnotation>(position: PositionEvent) -> U {
        let pin = U.init(
            memberCpf: position.cpf,
            teamId: position.teamId,
            memberName: "",
            equipment: nil
        )
        pin.coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
        if let positionedTeam = teamsManager.getTeam(id: position.teamId) {
            pin.memberName = positionedTeam.members
                .first(where: { $0.person.person.cpf == position.cpf })?
                .person.person.functionalName ?? ""
            pin.title = positionedTeam.team.name

            if let equipment = positionedTeam.team.equipments.first(where: { $0.id == position.equipmentId }) {
                pin.equipment = equipment
                pin.subtitle = equipment.formatName()
            }
        }
        return pin
    }

    private func createTeamMemberPin(position: PositionEvent) -> TeamMemberAnnotation {
        createPin(position: position)
    }

    private func createMyTeamMemberPin(position: PositionEvent) -> MyTeamMemberAnnotation {
        createPin(position: position)
    }

    private func compare(pin: TeamMemberAnnotation, andPosition position: PositionEvent) -> Bool {
        if let activeTeamId = cadService.getActiveTeam()?.id,
           teamsViewState == .teamsPins,
           position.teamId != activeTeamId {
            return position.equipmentId == pin.equipment?.id
        } else {
            return position.cpf == pin.memberCpf
        }
    }

    internal func setTeamsState() {
        self.mapView.annotations.forEach { annotation in
            guard let annotationView = mapView.view(for: annotation) as? TeamMemberAnnotationView else { return }
            annotationView.alpha = 1
            annotationView.updateSubtitle()
        }
    }

    internal func setMembersState(teamId: UUID) {
        self.mapView.annotations.forEach { annotation in
            guard let teamAnnotation = annotation as? TeamMemberAnnotation else { return }
            guard let annotationView = mapView.view(for: annotation) as? TeamMemberAnnotationView else { return }
            if teamAnnotation.teamId != teamId {
                annotationView.alpha = 0.6
            } else {
                annotationView.alpha = 1
            }
            annotationView.updateSubtitle()
        }
    }

    func setTeams(_ groupedPositions: [UUID: [PositionEvent]], shouldFocusOnTeam selectedTeam: UUID? = nil) {
        guard let activeTeamId = cadService.getActiveTeam()?.id else { return }

        self.positionsByTeam = Dictionary(uniqueKeysWithValues: groupedPositions.map { value in
            let (teamId, positions) = value
            if teamId == activeTeamId {
                return (teamId, positions)
            } else if let selectedTeam = selectedTeam, selectedTeam == teamId {
                return (teamId, positions)
            } else {
                let onePositionPerEquipment = positions.groupBy(path: \.equipmentId).values
                    .map { $0.first }.compactMap { $0 }
                return (teamId, onePositionPerEquipment)
            }
        })

        // Remove expired pins from map
        let expiredPins = self.pinsByTeam.values.map { pins in
            pins.filter { pin in
                guard let teamPositions = self.positionsByTeam[pin.teamId] else { return true }
                return !teamPositions.contains(where: { self.compare(pin: pin, andPosition: $0) })
            }
        }.flatMap { $0 }
        mapView.removeAnnotations(expiredPins)

        // Keep only non-expired pins
        self.pinsByTeam = self.pinsByTeam.mapValues { pins in
            pins.filter { pin in
                guard let teamPositions = self.positionsByTeam[pin.teamId] else { return false }
                return teamPositions.contains(where: { self.compare(pin: pin, andPosition: $0) })
            }
        }

        // Updating positions of existing pins
        self.positionsByTeam.forEach { value in
            let (teamId, positions) = value
            self.pinsByTeam[teamId]?.forEach { pin in
                guard let newPosition = positions.first(where: { self.compare(pin: pin, andPosition: $0) }) else { return }
                let newCoordinate = CLLocationCoordinate2D(latitude: newPosition.latitude, longitude: newPosition.longitude)
                pin.updatePosition(newCoordinate)
                if selectedTeam == teamId || activeTeamId == teamId {
                    pin.presentationState = .member
                } else {
                    pin.presentationState = .equipment
                }
            }
        }

        // Adding new pins
        self.positionsByTeam.forEach { value in
            let (teamId, positions) = value
            if let pinsByTeam = self.pinsByTeam[teamId] {
                let newPositions = positions.filter { position in
                    !pinsByTeam.contains(where: { self.compare(pin: $0, andPosition: position) })
                }
                let newPins = newPositions.map { position -> TeamMemberAnnotation in
                    if activeTeamId == position.teamId {
                        return self.createMyTeamMemberPin(position: position)
                    }

                    return self.createTeamMemberPin(position: position)
                }
                newPins.forEach { pin in
                    if selectedTeam == teamId || activeTeamId == teamId {
                        pin.presentationState = .member
                    } else {
                        pin.presentationState = .equipment
                    }
                }
                self.pinsByTeam[teamId] = self.pinsByTeam[teamId].map { $0 + newPins } ?? newPins
                self.mapView.addAnnotations(newPins)
            } else {
                let newPins = positions.map { position -> TeamMemberAnnotation in
                    if activeTeamId == position.teamId {
                        return self.createMyTeamMemberPin(position: position)
                    }

                    return self.createTeamMemberPin(position: position)
                }
                newPins.forEach { pin in
                    if selectedTeam == teamId || activeTeamId == teamId {
                        pin.presentationState = .member
                    } else {
                        pin.presentationState = .equipment
                    }
                }
                self.pinsByTeam[teamId] = newPins
                self.mapView.addAnnotations(newPins)
            }
        }
    }

    func fitInTeam(_ teamId: UUID) {
        if let teamPins = pinsByTeam[teamId] {
            fit(in: teamPins)
        }
    }

    func fitInMember(_ member: PositionedTeamMember) {
        let teamsMembersPositions = positionsByTeam.values.flatMap { $0 }
        let teamsMembersPins = pinsByTeam.values.flatMap { $0 }
        let teamPins = zip(teamsMembersPositions, teamsMembersPins)
            .filter { $0.0.cpf == member.person.person.cpf }
            .map { $1 }
        fit(in: teamPins)
    }

    func setTeamLabelsVisibility(for annotations: [MKAnnotation]) {
        annotations.forEach { annotation  in
            if let annotation = annotation as? TeamMemberAnnotation {
                if let annotationView = mapView.view(for: annotation) as? MyTeamMemberAnnotationView {
                    if self.showOccurrencesLabels {
                        annotationView.showLabel()
                    } else {
                        annotationView.hideLabel()
                    }
                } else if let annotationView = mapView.view(for: annotation) as? TeamMemberAnnotationView {
                    if self.showOccurrencesLabels {
                        annotationView.showLabel()
                    } else {
                        annotationView.hideLabel()
                    }
                }
            }
        }
    }
}
