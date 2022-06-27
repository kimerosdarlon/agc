//
//  HomeViewController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 22/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import SinespSegurancaAuthMobile
import AgenteDeCampoModule
import AgenteDeCampoCommon
import StoreKit
import UserNotifications
import CAD

class HomeViewController: UIViewController, ViewControllerProtocol, ModalTeamPresenter {

    private var collection = HomeCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var moduleCollectionDelegateDataSource = HomeCollectionViewDelegateDataSource()
    var termsController = TermsAgreementController()
    var resultController = SearchResultController(style: .grouped)
    var searchController: SearchController?
    private var alreadyRequest = false
    private var cadResource: CadResource?
    private var modalTeam: ModalTeamViewController?

    @CadServiceInject
    private var cadService: CadService

    @DispatchServiceInject
    private var dispatchService: DispatchService

    init(cadResource: CadResource?) {
        self.cadResource = cadResource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func modalTeamDidDismiss() {
        checkVersion()
        requestNotificationAuthorization()
        NotificationCenter.default.post(name: .homeScreenReady, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        self.searchController = SearchController(searchResultsController: self.resultController )
        self.setupState()
        if let team = cadResource?.resource.getActiveTeam(),
           let dispatches = cadResource?.dispatches,
           !cadService.hasStartedService() {
            modalTeam = ModalTeamViewController(withResource: .init(team: team, andDispatches: dispatches))
            modalTeam?.presenter = self
            modalTeam?.modalPresentationStyle = .fullScreen
            self.present(modalTeam!, animated: true, completion: nil)
        } else {
            NotificationCenter.default.post(name: .homeScreenReady, object: nil)
            requestNotificationAuthorization()
            checkVersion()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController?.viewDidAppear(animated)

        let termsStatus = UserService.shared.getTermsStatus()
        if termsStatus == nil || termsStatus!.agreed == false {
            self.termsController.presentModalIfNotAgreed(in: self)
        }
    }

    private func requestNotificationAuthorization() {
        if !alreadyRequest {
            alreadyRequest = true
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { authorized, _ in
                if authorized {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }

    private func checkVersion() {
        AppVersion.checkIfHasNewVersion { [weak self] (needUpdate, _ ) in
            if needUpdate {
                DispatchQueue.main.async {
                    if let this = self {
                        AppVersion().showUpdateMessage(in: this)
                    }
                }
            } else {
                AppVersion.updateBadge(hasUpdate: false)
            }
        }
    }

    func addSubviews() {
        view.addSubview(collection)
    }

    func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 4),
            collection.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 1),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: collection.trailingAnchor, multiplier: 1),
            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: collection.bottomAnchor, multiplier: 1)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        searchController?.viewWillAppear(animated)
    }

    func setupState() {
        self.view.backgroundColor = .appBackground
        self.collection.delegate = self.moduleCollectionDelegateDataSource
        self.collection.dataSource = self.moduleCollectionDelegateDataSource
        self.addSubviews()
        self.setupContraints()
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        self.moduleCollectionDelegateDataSource.delegate = self
        self.resultController.delegate = self
        self.resultController.filterDelegate = self
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.viewDidLayoutSubviews()
    }
}

extension HomeViewController: SearchDelegate {
    func present(controller: UIViewController, completion: (() -> Void)?) {
        navigationController?.pushViewController(controller, animated: true)
        completion?()
    }
}

extension HomeViewController: HomeCollectionViewDelegateDataSourceDelegate {

    func present(viewController: ModuleFilterViewControllerProtocol) {
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }

    func show(_ message: String) {
        alert(error: message)
    }
}
