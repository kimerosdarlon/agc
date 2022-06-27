//
//  RealTimeViewController+delegates.swift
//  CAD
//
//  Created by Samir Chaves on 06/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import MapKit

extension RealTimeViewController: RecentOccurrencesTableDelegate, RecentOccurrencesDataSourceDelegate {

    func didSelectAnOccurrence(_ occurrence: SimpleOccurrence) {
        loadingBar.isLoading = true
        currentDetailedOccurrence = occurrence
        mapView.selectedOccurrence = occurrence
        mapView.removeRoutes()
        mapView.showRoute(to: occurrence) {
            self.loadingBar.isLoading = false
        }
    }

    func didDeselectAnOccurrence() {
        currentDetailedOccurrence = nil
        mapView.selectedOccurrence = nil
        mapView.removeRoutes()
        mapView.fitInOccurrences()
        loadingBar.isLoading = false
    }

    func didZoomInOccurrence(_ occurrence: SimpleOccurrence) {
        mapView.navigateTo(occurrence)
    }

    func didRefreshOccurrences(completion: @escaping (Error?) -> Void) {
        occurrenceDataSource.refetch(completion: completion)
    }

    func didUpdateRecentOccurrences(_ occurrences: [SimpleOccurrence]) {
        mapView.setOccurrences(occurrences)
        menuTabsView.occurrences?.setOccurrences(occurrences)
    }

    func startLoading() {
        loadingBar.isLoading = true
    }

    func endLoading() {
        loadingBar.isLoading = false
    }

    func didOccurErrorInFetch(_ error: NSError) {
        if self.isUnauthorized(error) {
            self.gotoLogin(error.domain)
        } else {
            Toast.present(in: self, message: error.domain)
        }
    }
}

extension RealTimeViewController: NearTeamsDelegate {
    func didCloseDetails() {
        mapView.removeRoutes()
        mapView.teamsViewState = .teamsPins
        let teamsPositions = teamMembersManager.getTeamsPositions()
        mapView.setTeams(teamsPositions)
        mapView.setTeamsState()
    }

    func didSelectATeam(_ teamId: UUID) {
        currentDetailedTeamId = teamId
        mapView.teamsViewState = .teamMembersPins
        let teamsPositions = teamMembersManager.getTeamsPositions()
        mapView.setTeams(teamsPositions, shouldFocusOnTeam: teamId)
        mapView.fitInTeam(teamId)
        mapView.removeRoutes()
        mapView.setMembersState(teamId: teamId)
    }

    func didSelectAPositionedMember(_ member: PositionedTeamMember) {
        mapView.removeRoutes()
        loadingBar.isLoading = true
        mapView.showRoute(to: member) {
            self.loadingBar.isLoading = false
        }
    }

    func didSelectUserHimself() {
        mapView.centerMap()
        mapView.removeRoutes()
    }
}

extension RealTimeViewController: RealTimeMapViewDelegate {
    func didSelectOccurrenceAnnotation(_ occurrence: SimpleOccurrence) {
        openMenu()
        menuTabsView.goToOccurrenceDetails(occurrence)
        loadingBar.isLoading = true
        currentDetailedOccurrence = occurrence
        mapView.selectedOccurrence = occurrence
        mapView.removeRoutes()
        mapView.showRoute(to: occurrence) {
            self.loadingBar.isLoading = false
        }
    }
    func didSelectDispatchedOccurrenceAnnotation(_ occurrence: SimpleOccurrence) {
        openMenu()
        menuTabsView.goToOccurrenceDetails(occurrence, showDispatches: false)
        loadingBar.isLoading = true
        currentDetailedOccurrence = occurrence
        mapView.selectedOccurrence = occurrence
        mapView.removeRoutes()
        mapView.showRoute(to: occurrence) {
            self.loadingBar.isLoading = false
        }
    }

    func didSelectTeamAnnotation(_ teamId: UUID) { }

    func didSelectTeamMemberAnnotation(_ memberCpf: String, fromTeam teamId: UUID) {
        if let positionedTeam = teamMembersManager.getTeam(id: teamId) {
            openMenu()
            mapView.removeRoutes()
            if let positionedMember = positionedTeam.members.first(where: { $0.person.person.cpf == memberCpf }),
               mapView.teamsViewState == .teamMembersPins,
               currentDetailedTeamId == teamId {
                loadingBar.isLoading = true
                mapView.showRoute(to: positionedMember) {
                    self.loadingBar.isLoading = false
                }
            } else {
                mapView.teamsViewState = .teamMembersPins
                currentDetailedTeamId = teamId
                let teamsPositions = teamMembersManager.getTeamsPositions()
                mapView.setTeams(teamsPositions, shouldFocusOnTeam: teamId)
                mapView.fitInTeam(teamId)
                menuTabsView.goToTeamDetails(positionedTeam.team)
                mapView.setMembersState(teamId: teamId)
            }
        }
    }
}

extension RealTimeViewController: RTSearchResultsTableDelegate {
    func didSelectATeamResult(_ team: NonCriticalTeam) {
        openMenu()
        mapView.fitInTeam(team.id)
        menuTabsView.goToTeamDetails(team)
        mapView.removeRoutes()
    }

    func didSelectAnOccurrenceResult(_ occurrence: SimpleOccurrence) {
        openMenu()
        menuTabsView.goToOccurrenceDetails(occurrence)
        didSelectAnOccurrence(occurrence)
        mapView.removeRoutes()
    }

    func didSelectARecentSearch(_ query: String) { }
}

extension RealTimeViewController: TeamMembersManagerDelegate {
    func didUpdateTeams() {
        garanteeMainThread {
            let membersPositions = self.teamMembersManager.getTeamsPositions()
            if let currentSelectedTeam = self.currentDetailedTeamId {
                self.mapView.setTeams(membersPositions, shouldFocusOnTeam: currentSelectedTeam)
            } else {
                self.mapView.setTeams(membersPositions)
            }
        }
    }
}
