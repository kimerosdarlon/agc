//
//  RealTimeViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 05/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import MapKit
import AgenteDeCampoCommon
import CoreLocation
import Location

private class MenuDraggingHandler: UIView {
    let draggingBar: UIView = {
        let bar = UIView().enableAutoLayout().width(40).height(4)
        bar.backgroundColor = .appTitle
        bar.alpha = 0.4
        bar.layer.cornerRadius = 2
        return bar
    }()

    override func didMoveToSuperview() {
        addSubview(draggingBar)
        enableAutoLayout()
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        draggingBar.centerX(view: self).top(to: self.topAnchor, mutiplier: 1.2)
    }
}

public class RealTimeViewController: UIViewController {
    internal var bottomMenuPosition: NSLayoutConstraint?
    internal var overMapViewsPosition: NSLayoutConstraint?
    internal var positionController = MenuPositionController()
    internal var currentDetailedOccurrence: SimpleOccurrence?
    internal var currentDetailedTeamId: UUID?
    internal var overMapNavigation: OverMapNavigation?
    internal var mapView: RealTimeMapView!
    internal var menuTabsView: OccurrencesTeamsNavigationController!
    internal var teamMembersManager = TeamMembersManager.shared
    internal var occurrenceDataSource = RecentOccurrencesDataSource.shared
    internal var infoOverlay = MapInfoOverlayView()
    internal var locationStatus = LocationStatus.notDetermined
    internal var firstLoad = true

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    @RealTimeServiceInject
    private var realTimeService: RealTimeService

    @CadServiceInject
    private var cadService: CadService

    private var locationService = LocationService.shared
    private var trackingService = RTTrackingService.shared

    private let menuDragglingHandler: MenuDraggingHandler = {
        let handler = MenuDraggingHandler()
        handler.backgroundColor = .appBackground
        return handler
    }()

    let bottomMenu: UIView = {
        let view = UIView().enableAutoLayout()
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    internal let loadingBar = IndeterminateProgressBar()

    private let contentView = UIView()

    public init() {
        super.init(nibName: nil, bundle: nil)
        self.menuTabsView = OccurrencesTeamsNavigationController(superViewController: self)
        self.mapView = RealTimeMapView(delegate: self)
        self.mapView.getLocationStatus()
        overMapNavigation = OverMapNavigation(
            mapView: self.mapView,
            occurrencesDataSource: occurrenceDataSource,
            teamsManager: teamMembersManager,
            parentViewController: self
        )
        menuTabsView.occurrences?.delegate = self
        menuTabsView.teams?.delegate = self
        occurrenceDataSource.addDelegate(self)
        teamMembersManager.addDelegate(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentView)
        contentView.enableAutoLayout().fillSuperView(regardSafeArea: false)

        view.addSubview(infoOverlay.enableAutoLayout())
        infoOverlay.fillSuperView(regardSafeArea: false)
        infoOverlay.isHidden = true

        mapView.enableAutoLayout()
        contentView.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -25),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        navigationController?.setNavigationBarHidden(true, animated: false)

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleStatusChanged), name: .userLocationStatusDidChange, object: nil)
        center.addObserver(self, selector: #selector(handleResourceChanged), name: .cadResourceDidChange, object: nil)
        handleStatusChanged()

        addSubViews()
        layoutSubviews()
    }

    func setupViewToDeniedStatus() {
        infoOverlay.isHidden = false
        infoOverlay.state = .deny
    }

    func setupViewToNotDeterminateStatus() {
        infoOverlay.isHidden = false
        infoOverlay.state = .notDetermined
    }

    @objc func didReceivePosition(_ notitication: Notification) {
        guard let position = notitication.object as? PositionEvent else { return }
        self.teamMembersManager.addPosition(position) { error in
            garanteeMainThread {
                if error == nil {
                    let membersPositions = self.teamMembersManager.getTeamsPositions()
                    if let currentSelectedTeam = self.currentDetailedTeamId {
                        self.mapView.setTeams(membersPositions, shouldFocusOnTeam: currentSelectedTeam)
                    } else {
                        self.mapView.setTeams(membersPositions)
                    }
                } else {
                    let nsError = error! as NSError
                    if self.isUnauthorized(nsError) {
                        self.gotoLogin(nsError.domain)
                    } else {
                        Toast.present(in: self, message: nsError.domain)
                    }
                }
            }
        }
    }

    private func addSubViews() {
        contentView.addSubview(bottomMenu)
        bottomMenu.addSubview(menuDragglingHandler)
        contentView.addSubview(loadingBar)
        bottomMenu.insertSubview(menuTabsView.view.enableAutoLayout(), belowSubview: menuDragglingHandler)
        self.addChild(menuTabsView)
        menuTabsView.didMove(toParent: self)

        if let overMapNavigation = overMapNavigation {
            contentView.insertSubview(overMapNavigation, belowSubview: bottomMenu)
        }
    }

    private func layoutSubviews() {
        loadingBar.height(2)
        menuDragglingHandler
            .height(30)
            .centerX(view: bottomMenu)
            .width(bottomMenu)
            .top(to: bottomMenu.topAnchor, mutiplier: 0)

        bottomMenuPosition = bottomMenu.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -25)
        bottomMenuPosition?.isActive = true
        bottomMenu.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
        mapView.translateMap(-12.5)

        if let overMapNavigation = overMapNavigation {
            let safeArea = view.safeAreaLayoutGuide
            overMapNavigation.enableAutoLayout()
            overMapViewsPosition = overMapNavigation.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25)
            overMapViewsPosition?.isActive = true
            NSLayoutConstraint.activate([
                overMapNavigation.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: -25),
                overMapNavigation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                overMapNavigation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            loadingBar.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor),
            loadingBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            loadingBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            bottomMenu.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomMenu.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomMenu.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            menuTabsView.view.topAnchor.constraint(equalTo: bottomMenu.topAnchor, constant: 25),
            menuTabsView.view.leadingAnchor.constraint(equalTo: bottomMenu.leadingAnchor),
            menuTabsView.view.trailingAnchor.constraint(equalTo: bottomMenu.trailingAnchor),
            menuTabsView.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 83)
        ])
    }

    func setupViewToAuthorizedStatus() {
        infoOverlay.isHidden = true
        if firstLoad {
            mapView.centerMap()
            firstLoad = false
            if let userLocation = locationService.currentLocation?.coordinate {
                mapView.setPin(location: userLocation)
                mapView.setCircle(center: userLocation)
            }
        }

        if let activeTeam = cadService.getActiveTeam() {
            let operatingRegionsIds = activeTeam.operatingRegions.map { $0.id }
            realTimeService.switchToOperatingRegionsStream(ids: operatingRegionsIds)
        }
        teamMembersManager.addMyTeam()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didReceivePosition(_:)), name: .realTimeReceivePosition, object: nil)
//        center.addObserver(self, selector: #selector(teamDidDispatch(_:)), name: .cadTeamDidDispatch, object: nil)
        center.addObserver(self, selector: #selector(focusOnDispatchedOccurrence), name: .cadDidDispatchedOccurrenceFocus, object: nil)

        trackingService.stopSendingUserLocation()
        trackingService.scheduleSendingUserLocation()
    }

    @objc private func focusOnDispatchedOccurrence() {
        let activeTeams = teamMembersManager.activeTeams
        guard let dispatchedOccurrence = cadService.getDispatchedOccurrence() else { return }
        let activeDispatchStatus: [DispatchStatusCode] = [
            .arrived, .arrivedAtIntermediatePlace, .dispatched, .moving, .movingToIntermediatePlace
        ]
        let allocatedTeams = dispatchedOccurrence.dispatches.filter { dispatch in
            let isNotFinished = activeDispatchStatus.contains { code in
                guard let status = DispatchStatus.getStatusBy(code: code) else { return true }
                return status.raw.description == dispatch.status
            }
            let isTeamActive = activeTeams.isEmpty || activeTeams.contains(where: { $0.id == dispatch.team.id })
            return isNotFinished && isTeamActive
        }.map { $0.team }
        
        let simpleOccurrence = dispatchedOccurrence.toSimple(allocatedTeams: allocatedTeams)
        openMenu()
        menuTabsView.goToOccurrenceDetails(simpleOccurrence)
        loadingBar.isLoading = true
        currentDetailedOccurrence = simpleOccurrence
        mapView.selectedOccurrence = simpleOccurrence
        mapView.removeRoutes()
        mapView.showRoute(to: simpleOccurrence) {
            self.loadingBar.isLoading = false
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        mapView.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        positionController.parentHeight = view.bounds.height
    }

    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let currentY = gesture.translation(in: self.view).y
        let velocity = gesture.velocity(in: self.view).y
        let deceleratedY = currentY + velocity / 35

        if gesture.state == .began {
            positionController.initialMenuLocation = self.bottomMenuPosition?.constant ?? 0
        } else if gesture.state == .changed {
            positionController.currentMenuLocation = positionController.initialMenuLocation + deceleratedY
            var draggingLocation = positionController.initialMenuLocation + currentY
            draggingLocation = draggingLocation > positionController.bottomLocation ? positionController.bottomLocation : draggingLocation
            if draggingLocation > positionController.middleLocation {
                self.overMapViewsPosition?.constant = draggingLocation
                self.mapView.translateMap(draggingLocation / 2)
            } else {
                let alphaFactor = 1 - (draggingLocation - positionController.middleLocation) / (positionController.topLocation - positionController.middleLocation)
                self.overMapNavigation?.alpha = pow(alphaFactor, 3)
                self.overMapViewsPosition?.constant = positionController.middleLocation
                self.mapView.translateMap(positionController.middleLocation / 2)
            }
            self.bottomMenuPosition?.constant = draggingLocation
            self.view.layoutIfNeeded()
        } else if gesture.state == .ended {
            positionController.setMenuPosition()
            let menuLocation = positionController.getMenuLocation()
            let mapLocation = positionController.getMapLocation()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.bottomMenuPosition?.constant = menuLocation
                self.overMapViewsPosition?.constant = mapLocation * 2
                if menuLocation == self.positionController.topLocation {
                    self.overMapNavigation?.alpha = 0
                } else {
                    self.overMapNavigation?.alpha = 1
                }
                self.mapView.translateMap(mapLocation)
                self.view.layoutIfNeeded()
            }
        }
    }

    internal func openMenu() {
        if positionController.currentPosition == .bottom {
            positionController.currentPosition = .middle
            let mapLocation = positionController.getMapLocation()
            let menuLocation = positionController.middleLocation
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.bottomMenuPosition?.constant = menuLocation
                self.overMapViewsPosition?.constant = mapLocation * 2
                self.mapView.translateMap(mapLocation)
                self.view.layoutIfNeeded()
            }
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LocationService.status.isAuthorized && cadService.hasActiveTeam() {
            locationService.startUpdatingLocation()
        }

        navigationController?.setNavigationBarHidden(true, animated: true)
        occurrenceDataSource.startRefreshing()
        teamMembersManager.startRefreshing()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        occurrenceDataSource.stopRefreshing()
        teamMembersManager.stopRefreshing()
    }

    @objc func handleResourceChanged() {
        garanteeMainThread {
            if !self.cadService.hasActiveTeam() {
                self.locationService.stopUpdatingLocation()
                self.trackingService.stopSendingUserLocation()
            }

            switch LocationService.status {
            case .always:
                if self.cadService.hasActiveTeam() {
                    self.setupViewToAuthorizedStatus()
                } else {
                    self.infoOverlay.isHidden = false
                    self.infoOverlay.state = .noActiveTeam
                }
            case .denied, .whenInUse:
                self.setupViewToDeniedStatus()
            case .notDetermined:
                self.setupViewToNotDeterminateStatus()
            }
        }
    }

    @objc func handleStatusChanged() {
        switch LocationService.status {
        case .always:
            if cadService.hasActiveTeam() {
                if infoOverlay.state != .allowed {
                    setupViewToAuthorizedStatus()
                    infoOverlay.state = .allowed
                }
            } else {
                infoOverlay.isHidden = false
                infoOverlay.state = .noActiveTeam
            }
        case .denied, .whenInUse:
            setupViewToDeniedStatus()
        case .notDetermined:
            setupViewToNotDeterminateStatus()
        }
    }
}
