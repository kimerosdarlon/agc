//
//  TeamMembersManager.swift
//  CAD
//
//  Created by Samir Chaves on 12/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import Logger
import AgenteDeCampoCommon

protocol TeamMembersManagerDelegate: class {
    func didUpdateTeams()
}

class TeamMembersManager {
    private var delegates = [TeamMembersManagerDelegate?]()

    private let logger = Logger.forClass(TeamMembersManager.self)
    static let shared = TeamMembersManager()

    private let externalSetting = ExternalSettingsService.settings

    private var refreshingTimer: Timer?

    @CadServiceInject
    private var cadService: CadService

    private var teamsById = [UUID: PositionedTeam]()

    var activeTeams = [TeamBasic]()
    private var currentTeamId: UUID?

    func getTeam(id: UUID) -> PositionedTeam? {
        teamsById[id]
    }

    func getOnlineTeams() -> [NonCriticalTeam] {
        teamsById.values.map { $0.team }
    }

    func getPositionedMembers() -> [PositionedTeamMember] {
        return teamsById.values.flatMap { $0.members }
    }

    func getMembersPositions(teamId: UUID) -> [PositionEvent] {
        return teamsById.values
            .first(where: { $0.team.id == teamId })?
            .members
            .map { $0.position } ?? []
    }

    func getTeamsPositions() -> [UUID: [PositionEvent]] {
        var groupedPositions = [UUID: [PositionEvent]]()
        for (teamId, positionedTeam) in teamsById {
            groupedPositions[teamId] = positionedTeam.members
                .map { $0.position }
                .sorted { (a, b) in
                    a.eventTimestamp > b.eventTimestamp
                }
        }
        return groupedPositions
    }

    private func searchMatch(query: NSRegularExpression, with term: String) -> NSRange? {
        let foldedTerm = term.prepareForSearch()
        let range = NSRange(location: 0, length: foldedTerm.utf16.count)
        return query.firstMatch(in: foldedTerm, options: [], range: range)?.range
    }

    enum ResultTeamField: String {
        case name = "Nome"
        case operatingRegion = "Região de Atuação"
        case members = "Equipe"
        case situation = "Situação"
        case equipment = "Equipamento"
    }

    struct SearchResult {
        let field: ResultTeamField
        let value: String
        let range: NSRange
        let team: NonCriticalTeam
    }

    typealias SearchField = (field: ResultTeamField, value: String)

    private func teamMatches(team: NonCriticalTeam, with query: NSRegularExpression) -> SearchResult? {
        var fieldsToCheck: [SearchField] = [(field: .name, value: team.name)]

        // Operating Regions
        fieldsToCheck.append(
            contentsOf: team.operatingRegions.flatMap { or in
                [or.agency.initials, or.agency.name, or.initials, or.initials]
            }.compactMap { $0 }
            .map { (field: .operatingRegion, value: $0) }
        )

        // People
        fieldsToCheck.append(
            contentsOf: team.teamPeople.map { $0.person.name }.map { (field: .members, value: $0) }
        )

        // Equipments
        fieldsToCheck.append(
            contentsOf: team.equipments.flatMap { equipment in
                [equipment.brand, equipment.model, equipment.prefix, equipment.plate]
            }.compactMap { $0 }
            .map { (field: .equipment, value: $0) }
        )

        return fieldsToCheck.first { searchField in
            return searchMatch(query: query, with: searchField.value) != nil
        }.map { searchField in
            let range = searchMatch(query: query, with: searchField.value)
            let emptyRange = NSRange(location: 0, length: 0)
            return SearchResult(
                field: searchField.field,
                value: searchField.value,
                range: range ?? emptyRange,
                team: team
            )
        }
    }

    func search(by query: String) -> [SearchResult] {
        guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(), options: [.caseInsensitive, .ignoreMetacharacters]) else { return [] }
        return teamsById.values.map { $0.team }.map { team in
            teamMatches(team: team, with: queryRegex)
        }.compactMap { $0 }
    }

    func addMyTeam() {
        guard let activeTeam = cadService.getActiveTeam() else { return }
        let nonCriticalActiveTeam = activeTeam.toNonCritical()
        if let currentTeamId = currentTeamId {
            teamsById.removeValue(forKey: currentTeamId)
        }
        teamsById[activeTeam.id] = PositionedTeam(team: nonCriticalActiveTeam, members: [])
        currentTeamId = activeTeam.id
        delegates.forEach { $0?.didUpdateTeams() }
    }

    private func removeExpiredPositions() {
        // Removing expired members
        self.teamsById = teamsById.mapValues { team in
            let nonExpiredMembers = team.members.filter { member in
                let position = member.position
                let date = Date(timeIntervalSince1970: TimeInterval(position.receivedAt / 1000))
                let timeDiff = date.timeIntervalSinceNow
                return abs(timeDiff) <= (externalSetting.realTime.positionsCleanTimeout / 1000)
            }
            return PositionedTeam(team: team.team, members: nonExpiredMembers)
        }.filter { (_, positionedTeam) in
            return !positionedTeam.members.isEmpty || positionedTeam.team.id == self.currentTeamId
        }
    }

    func addPosition(_ position: PositionEvent, completion: @escaping (Error?) -> Void) {
        // The use can receive you own position

        // Get current user CPF
        guard let userCpf = cadService.getProfile()?.person.cpf else {
            completion(nil)
            return
        }
        let teamId = position.teamId

        // Verify if the position belongs to a members of an already existing team
        // and this members is not the current user
        if teamsById.keys.contains(teamId) && position.cpf != userCpf {
            var positionedTeam = teamsById[teamId]!
            var positionedMembers = positionedTeam.members

            // Check if the member is already positioned
            if let currentMember = positionedMembers.first(where: { matchPersonAndPosition(person: $0.person, position: position) }) {
                positionedTeam.members = positionedMembers.map { member in
                    if member.person.person.cpf == currentMember.person.person.cpf {
                        return PositionedTeamMember(person: member.person, position: position)
                    }
                    return member
                }
                teamsById[teamId] = positionedTeam
            } else if let teamPerson = positionedTeam.team.teamPeople.first(where: { matchPersonAndPosition(person: $0, position: position)
            }) {
                // If not, it will be positioned.
                let newMember = PositionedTeamMember(person: teamPerson, position: position)
                positionedMembers.append(newMember)
                positionedTeam.members = positionedMembers
                teamsById[teamId] = positionedTeam
            }
            removeExpiredPositions()
            completion(nil)
        } else {
            if position.cpf == userCpf {
                self.teamsById = self.teamsById.filter { (_, positionedTeam) in
                    return !(positionedTeam.members.isEmpty && positionedTeam.team.id != position.teamId)
                }
                self.delegates.forEach { $0?.didUpdateTeams() }
                self.removeExpiredPositions()
                completion(nil)
            } else {
                self.teamsById = self.teamsById.filter { (_, positionedTeam) in
                    return !positionedTeam.members.contains { $0.person.person.cpf == position.cpf }
                }

                cadService.getTeamById(teamId: teamId) { result in
                    switch result {
                    case .success(let team):
                        let members = team.teamPeople
                            .first(where: { self.matchPersonAndPosition(person: $0, position: position) })
                            .map { [PositionedTeamMember(person: $0, position: position)] } ?? []
                        let positionedTeam = PositionedTeam(team: team, members: members)

                        self.teamsById[teamId] = positionedTeam
                        self.delegates.forEach { $0?.didUpdateTeams() }
                        self.removeExpiredPositions()
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            }
        }
    }

    func addDelegate(_ delegate: TeamMembersManagerDelegate) {
        delegates.append(delegate)
    }

    private func matchPersonAndPosition(person: SimpleTeamPerson, position: PositionEvent) -> Bool {
        if let personCpf = person.person.cpf {
            return personCpf.elementsEqual(position.cpf)
        }
        return false
    }

    func removeInactiveTeams(completion: @escaping () -> Void) {
        guard let activeTeam = cadService.getActiveTeam() else { return }
        let operatingRegionsIds = activeTeam.operatingRegions.map { $0.id }
        cadService.getActiveTeams(operatingRegionsIds: operatingRegionsIds) { result in
            switch result {
            case .success(let activeTeams):
                self.teamsById = self.teamsById.filter { (_, positionedTeam) in
                    activeTeams.contains { $0.id == positionedTeam.team.id }
                }
                self.activeTeams = activeTeams
                completion()
            case .failure:
                completion()
            }
        }
    }

    func startRefreshing() {
        refreshingTimer?.invalidate()
        self.refreshingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.removeExpiredPositions()
            self.removeInactiveTeams {
                self.delegates.forEach { $0?.didUpdateTeams() }
            }
        }
    }

    func stopRefreshing() {
        refreshingTimer?.invalidate()
    }

    func updateTeams(operatingRegions: [UUID]) {
        self.teamsById = self.teamsById.filter { (teamId, team) in
            if teamId == currentTeamId { return true }
            return team.team.operatingRegions.allSatisfy { operatingRegions.contains($0.id) }
        }
        self.delegates.forEach { $0?.didUpdateTeams() }
    }
}
