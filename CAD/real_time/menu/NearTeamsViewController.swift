//
//  NearTeams.swift
//  CAD
//
//  Created by Samir Chaves on 11/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import CoreLocation
import Location

protocol NearTeamsDelegate: class {
    func didSelectATeam(_ teamId: UUID)
    func didSelectAPositionedMember(_ member: PositionedTeamMember)
    func didSelectUserHimself()
    func didCloseDetails()
}

class NearTeamsViewController: UITableViewController {
    enum Section: Hashable {
        case main
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, NonCriticalTeam>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NonCriticalTeam>
    private var dataSource: DataSource?
    private var snapshot: Snapshot

    weak var delegate: NearTeamsDelegate?

    private let teamMembersManager = TeamMembersManager.shared
    private let locationService = LocationService.shared
    
    private let countLabel = UILabel.build(withSize: 12, alpha: 0.7, color: .appTitle)

    @CadServiceInject
    private var cadService: CadService

    private var currentTeams = [NonCriticalTeam]()

    private var myTeamDetailView: NearTeamDetailView?

    init() {
        snapshot = Snapshot()
        super.init(nibName: nil, bundle: nil)
        dataSource = makeDataSource()
        title = "Equipes"
        tableView.register(NearTeamTableViewCell.self, forCellReuseIdentifier: NearTeamTableViewCell.identifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        countLabel.frame = .init(x: 0, y: 0, width: 80, height: 30)
        tableView.tableHeaderView = countLabel.height(30)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.canCancelContentTouches = false
        tableView.delaysContentTouches = false
        tableView.isExclusiveTouch = false
    }

    func setTeams(_ teams: [NonCriticalTeam]) {
        garanteeMainThread {
            self.snapshot.deleteAllItems()
            self.snapshot.appendSections([.main])
            if teams.count == 1 {
                var onlinePeopleCpf = self.teamMembersManager.getPositionedMembers()
                    .map { $0.person.person.cpf }
                    .compactMap { $0 }
                if let userCpf = self.cadService.getProfile()?.person.cpf {
                    onlinePeopleCpf.append(userCpf)
                }
                if self.currentTeams.count == 1 && teams.first?.id == self.currentTeams.first?.id {
                    self.myTeamDetailView?.updateOnlineMembers(cpfs: onlinePeopleCpf)
                } else {
                    self.snapshot.appendItems([])
                    let myTeam = teams.first!
                    self.myTeamDetailView = NearTeamDetailView(team: myTeam, onlineMembersCpfs: onlinePeopleCpf)
                    self.myTeamDetailView?.teamDelegate = self
                    self.tableView.backgroundView = self.myTeamDetailView
                }
                self.countLabel.isHidden = true
            } else {
                self.countLabel.isHidden = false
                self.countLabel.text = "    \(teams.count) equipes"
                self.snapshot.appendItems(teams)
                self.tableView.backgroundView = UIView()
            }
            self.dataSource?.apply(self.snapshot, animatingDifferences: false) {
                self.currentTeams = teams
            }
        }
    }

    private func makeDataSource() -> DataSource {
        return DataSource(
            tableView: tableView,
            cellProvider: { (tableView, indexPath, team) -> NearTeamTableViewCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: NearTeamTableViewCell.identifier, for: indexPath) as? NearTeamTableViewCell
                cell?.configure(with: team)
                
                return cell
            }
        )
    }
}

extension NearTeamsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedTeam = dataSource?.itemIdentifier(for: indexPath) else { return }
        let detailsViewController = NearTeamDetailViewController(team: selectedTeam)
        detailsViewController.delegate = self
        delegate?.didSelectATeam(selectedTeam.id)
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

extension NearTeamsViewController: NearTeamDetailDelegate {
    func didSelectOnlineMember(_ member: SimpleTeamPerson) {
        if let positionedMember = teamMembersManager.getPositionedMembers()
                .first(where: { $0.person.person.cpf == member.person.cpf }) {
            delegate?.didSelectAPositionedMember(positionedMember)
        } else if let userCpf = cadService.getProfile()?.person.cpf, userCpf == member.person.cpf {
            delegate?.didSelectUserHimself()
        }
    }

    func didCloseDetails() {
        delegate?.didCloseDetails()
    }

    func didRouteToMember(_ member: SimpleTeamPerson) {
        guard let positionedMember = teamMembersManager.getPositionedMembers()
                .first(where: { $0.person.person.cpf == member.person.cpf }) else { return }
        let position = positionedMember.position
        openMaps(from: locationService.currentLocation?.coordinate, to: CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude))
    }
}
