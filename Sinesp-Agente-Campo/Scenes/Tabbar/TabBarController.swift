//
//  TabBarController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 22/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
import Warrant
import CAD

struct AppTabItens {
    let title: String
    let icon: UIImage?
    let badge: Int
    let controller: UINavigationController
}

class TabBarController: UITabBarController {

    static let bottomBarHeight: CGFloat = 70

    private var isCadResource = false

    private var tabBarControllers: [AppTabItens]
    private var navigationControllers = [TabNavigationController]()

    private var footerView = UIView().enableAutoLayout()
    private var footerViewHeightConstraint: NSLayoutConstraint?

    private var dispatchBar: DispatchBarView?
    private var cadNotificationController: CadNotificationUIController?
    private var cadLocationNotificationManager = CadLocationBasedNotificationManager.shared
    private let cadResource: CadResource?

    @DispatchServiceInject
    private var dispatchService: DispatchService

    internal let bgStorage = CADBackgroundStorageManager.shared

    private var cadNotificationViewController: CadNotificationUIController!

    init(with itens: [AppTabItens], cadResource: CadResource?) {
        self.cadResource = cadResource
        self.tabBarControllers = itens
        super.init(nibName: nil, bundle: nil)
        if dispatchBar == nil {
            dispatchBar = DispatchBarView(parentViewController: self).enableAutoLayout()
            cadNotificationController = CadNotificationUIController(rootViewController: self)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapOnFooter() {
        print("rop")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if dispatchBar == nil {
            dispatchBar = DispatchBarView(parentViewController: self).enableAutoLayout()
            cadNotificationController = CadNotificationUIController(rootViewController: self)
        }

        navigationControllers = self.tabBarControllers.map({ TabNavigationController(rootNavigation: $0.controller) })
        viewControllers = navigationControllers
        setupTabBar()

        view.addSubview(footerView)

        footerView.width(view).bottom(to: tabBar.topAnchor, 0)
        footerView.clipsToBounds = true

        if let dispatchBar = dispatchBar {
            dispatchBar.delegate = self
            footerView.addSubview(dispatchBar)
            NSLayoutConstraint.activate([
                dispatchBar.topAnchor.constraint(equalTo: footerView.topAnchor),
                dispatchBar.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
                dispatchBar.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
                dispatchBar.trailingAnchor.constraint(equalTo: footerView.trailingAnchor)
            ])
        }

        footerViewHeightConstraint = footerView.heightAnchor.constraint(equalToConstant: 0)
        footerViewHeightConstraint?.isActive = true

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(setupTabBar), name: .updateBadgeCount, object: nil)
        center.addObserver(self, selector: #selector(teamDidDispatch(_:)), name: .cadTeamDidDispatch, object: nil)
        center.addObserver(self, selector: #selector(teamDidFinishDispatch), name: .cadTeamDidFinishDispatch, object: nil)
        center.addObserver(self, selector: #selector(cadResourceDidChage(_:)), name: .cadResourceDidChange, object: nil)
        center.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        center.addObserver(self, selector: #selector(didDetailAnOccurrence(_:)), name: .cadDidDetailAnOccurrence, object: nil)
        center.addObserver(self, selector: #selector(didDownloadAnOccurrence(_:)), name: .cadDidDownloadAnOccurrence, object: nil)
        center.addObserver(self, selector: #selector(userUnauthenticated(_:)), name: .userUnauthenticated, object: nil)
        center.addObserver(self, selector: #selector(handleHomeScreenReady), name: .homeScreenReady, object: nil)

        cadNotificationViewController = CadNotificationUIController(rootViewController: self)
        cadNotificationViewController.handleNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func userUnauthenticated(_ notification: Notification) {
        if let error = notification.object as? NSError {
            garanteeMainThread {
                self.gotoLogin(error.domain)
            }
        }
    }

    @objc private func didDetailAnOccurrence(_ notification: Notification) {
        if let occurrence = notification.userInfo?["details"] as? OccurrenceDetails {
            let detailsViewController = OccurrenceDetailNavigationController(occurrence: occurrence)
            present(detailsViewController, animated: true)
        }
    }

    @objc private func didDownloadAnOccurrence(_ notification: Notification) {
        if let pdfURL = notification.userInfo?["pdfUrl"] as? URL {
            let pdfScreen = PDFNavigationController(pdfURL: pdfURL)
            present(pdfScreen, animated: true)
        }
    }

    private func setupLayoutForDispatchBar() {
        footerView.clipsToBounds = false
        navigationControllers.forEach { $0.showFooter() }
        let barHeight = TabBarController.bottomBarHeight
        UIView.animate(withDuration: 0.3) {
            self.footerViewHeightConstraint?.constant = barHeight
            self.tabBar.layoutIfNeeded()
        }
    }

    @objc private func handleHomeScreenReady() {
        if let cadResource = cadResource,
           let activeTeamId = cadResource.resource.activeTeam,
           let currentTeam = cadResource.resource.teams.first(where: { $0.id == activeTeamId }),
           let dispatch = cadResource.dispatches?.first {
            setupDispatchBar(with: dispatch.occurrenceId,
                             dispatch: dispatch.toDispatch(team: currentTeam),
                             statusCode: dispatch.statusCode)
        }
    }

    private func setupDispatchBar(with occurrenceId: UUID, dispatch: Dispatch, statusCode: DispatchStatusCode) {
        if !self.dispatchService.isDispatchConfirmed(of: dispatch.team.id, in: occurrenceId) {
            self.cadNotificationController?.playSirenSound()
            self.cadNotificationController?.showDispatchConfirmAlert(teamId: dispatch.team.id, occurrenceId: occurrenceId)
        }
        dispatchBar?.configure(with: occurrenceId, dispatch: dispatch, statusCode: statusCode)
        setupLayoutForDispatchBar()
    }

    @objc private func teamDidDispatch(_ notification: Notification) {

        guard UIApplication.shared.applicationState == .active else { return }
        bgStorage.currentDispatchReleased = false

        if let occurrence = notification.userInfo?["occurrence"] as? OccurrencePushNotification {
            dispatchBar?.configure(with: occurrence.occurrenceDetails, dispatch: occurrence.dispatch)
            setupLayoutForDispatchBar()
        } else if let occurrenceId = notification.userInfo?["occurrenceId"] as? UUID,
                  let dispatch = notification.userInfo?["dispatch"] as? Dispatch,
                  let statusCode = notification.userInfo?["statusCode"] as? DispatchStatusCode {
            setupDispatchBar(with: occurrenceId, dispatch: dispatch, statusCode: statusCode)
        }
    }

    @objc private func cadResourceDidChage(_ notification: Notification) {
        garanteeMainThread {
            if let cadResourceOpt = notification.userInfo?["resource"] as? CadResource?,
               let cadResource = cadResourceOpt {
                if let dispatch = cadResource.dispatches?.first,
                   let activeTeam = cadResource.resource.teams.first(where: { $0.id == cadResource.resource.activeTeam }) {
                    self.dispatchBar?.configure(
                        with: dispatch.occurrenceId,
                        dispatch: dispatch.toDispatch(team: activeTeam),
                        statusCode: dispatch.statusCode
                    )
                    self.setupLayoutForDispatchBar()
                } else {
                    self.dispatchService.cleanStoredDispatchConfirm()
                }
            }
        }
    }

    @objc private func teamDidFinishDispatch() {
        footerView.clipsToBounds = true
        navigationControllers.forEach { $0.hideFooter() }
        dispatchService.cleanStoredDispatchConfirm()
        cadLocationNotificationManager.removeAllDeliveredNotifications()
        UIView.animate(withDuration: 0.3) {
            self.footerViewHeightConstraint?.constant = 0
            self.tabBar.layoutIfNeeded()
            self.bgStorage.currentDispatchedOccurrence = nil
            self.bgStorage.currentDispatchReleased = true
        }
    }

    @objc private func setupTabBar() {
        for index in 0..<tabBarControllers.count {
            tabBar.items?[index].title = tabBarControllers[index].title
            tabBar.items?[index].image = tabBarControllers[index].icon
            if tabBarControllers[index].badge > 0 {
                tabBar.items?[index].badgeValue = "\(tabBarControllers[index].badge)"
            } else {
                tabBar.items?[index].badgeValue = nil
            }
        }
        tabBar.barTintColor = .appBackground
        tabBar.isTranslucent = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    @objc private func appBecomeActive() {
        if let currentOccurrence = bgStorage.currentDispatchedOccurrence {
            dispatchBar?.configure(with: currentOccurrence.occurrenceDetails, dispatch: currentOccurrence.dispatch)
            setupLayoutForDispatchBar()
        } else if bgStorage.currentDispatchReleased == true {
            teamDidFinishDispatch()
        }
    }
}

extension TabBarController: DispatchBarViewDelegate {
    func didOpenMenu() {
        navigationControllers.forEach { $0.blur() }
    }

    func didCloseMenu() {
        navigationControllers.forEach { $0.focus() }
    }

    func didGetError(_ error: NSError) {
        if self.isUnauthorized(error) {
            garanteeMainThread {
                self.gotoLogin(error.domain)
            }
        }
    }
}
