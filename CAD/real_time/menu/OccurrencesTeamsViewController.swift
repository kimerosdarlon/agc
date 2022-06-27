//
//  OccurrencesTeamsViewController.swift
//  CAD
//
//  Created by Samir Chaves on 09/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import ViewPager_Swift
import AgenteDeCampoCommon
import CoreLocation
import Location

class OccurrencesTeamsNavigationController: UINavigationController {
    let viewController: OccurrencesTeamsViewController
    var occurrences: RecentOccurrencesTableViewController?
    var teams: NearTeamsViewController?
    private let teamsManager = TeamMembersManager.shared
    private let locationService = LocationService.shared

    init(superViewController: UIViewController) {
        viewController = OccurrencesTeamsViewController(rootViewController: superViewController)
        occurrences = viewController.occurrences
        teams = viewController.teams
        super.init(rootViewController: viewController)
        hidesBottomBarWhenPushed = true
        isToolbarHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        setToolbarHidden(true, animated: false)
        viewController.view.translatesAutoresizingMaskIntoConstraints = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    func goToOccurrenceDetails(_ occurrence: SimpleOccurrence, showDispatches: Bool = true) {
        if viewControllers.count >= 2 {
            popViewController(animated: false)
        }
        let occurrenceDetailsViewController = RecentOccurrenceViewController(occurrence: occurrence, showDispatches: showDispatches)
        occurrenceDetailsViewController.delegate = self
        pushViewController(occurrenceDetailsViewController, animated: true)
    }

    func goToTeamDetails(_ team: NonCriticalTeam) {
        popViewController(animated: false)
        let teamDetailsViewController = NearTeamDetailViewController(team: team)
        teamDetailsViewController.delegate = self
        pushViewController(teamDetailsViewController, animated: true)
    }
}

extension OccurrencesTeamsNavigationController: NearTeamDetailDelegate {
    func didSelectOnlineMember(_ member: SimpleTeamPerson) {
        guard let positionedMember = teamsManager.getPositionedMembers()
                .first(where: { $0.person.person.cpf == member.person.cpf }) else { return }
        teams?.delegate?.didSelectAPositionedMember(positionedMember)
    }

    func didCloseDetails() {
        teams?.delegate?.didCloseDetails()
    }

    func didRouteToMember(_ member: SimpleTeamPerson) {
        guard let positionedMember = teamsManager.getPositionedMembers()
                .first(where: { $0.person.person.cpf == member.person.cpf }) else { return }
        let position = positionedMember.position
        openMaps(
            from: locationService.currentLocation?.coordinate,
            to: CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
        )
    }
}

extension OccurrencesTeamsNavigationController: RecentOccurrenceDelegate {
    func didBack() {
        occurrences?.didBack()
    }

    func didTapInDetailsButton(_ occurrenceId: UUID, completion: @escaping () -> Void) {
        occurrences?.didTapInDetailsButton(occurrenceId, completion: completion)
    }
}

class OccurrencesTeamsViewController: UIViewController {
    var controllers = [UIViewController]()
    var viewPager: ViewPager!
    var occurrences: RecentOccurrencesTableViewController?
    var teams: NearTeamsViewController?
    private let teamsManager = TeamMembersManager.shared
    private var initialPage = 0

    @CadServiceInject
    private var cadService: CadService

    private let pagerOptions: ViewPagerOptions = {
        let option = AppDefaults().pagerOptions
        option.tabViewHeight = 45
        option.distribution = .segmented
        option.tabViewPaddingLeft = 10
        option.tabViewTextFont = UIFont.systemFont(ofSize: 15.0)
        option.shadowOpacity = 0.1
        return option
    }()

    init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        teams = NearTeamsViewController()
        occurrences = RecentOccurrencesTableViewController(rootViewController: rootViewController)
        teamsManager.addDelegate(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        if cadService.realtimeOccurrencesAllowed() {
            controllers.append(contentsOf: [occurrences!, teams!])
            navigationController?.isNavigationBarHidden = true

            viewPager = ViewPager(viewController: self)
            viewPager.setOptions(options: pagerOptions)
            viewPager.setDataSource(dataSource: self)
            viewPager.setDelegate(delegate: self)
            viewPager.build()

            view.height(1000)
            view.layer.masksToBounds = true
        } else {
            view.addSubview(teams!.view)
            teams!.view.enableAutoLayout()
            teams!.view.fillSuperView(regardSafeArea: false)
            addChild(teams!)
            teams?.didMove(toParent: self)
            view.layer.masksToBounds = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension OccurrencesTeamsViewController: TeamMembersManagerDelegate {
    func didUpdateTeams() {
        let onlineTeams = teamsManager.getOnlineTeams()
        teams?.setTeams(onlineTeams)
    }
}

extension OccurrencesTeamsViewController: ViewPagerDataSource, ViewPagerDelegate {

    func numberOfPages() -> Int { controllers.count }

    func viewControllerAtPosition(position: Int) -> UIViewController { controllers[position] }

    func tabsForPages() -> [ViewPagerTab] {
        return controllers.map({ ViewPagerTab(title: $0.title ?? "Sem título", image: nil) })
    }

    func startViewPagerAtIndex() -> Int { initialPage }

    func willMoveToControllerAtIndex(index: Int) { }

    func didMoveToControllerAtIndex(index: Int) { }
}
