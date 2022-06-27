//
//  LoginViewController+SinespAuthDelegate.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 06/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import SinespSegurancaAuthMobile
import SwiftyBeaver
import AgenteDeCampoCommon
import AgenteDeCampoModule
import UIKit
import OcurrencyBulletin
import Vehicle
import Warrant
import Driver
import Location
import CAD

extension LoginViewController: SinespAuthDelegate {

    func didFinished(with model: LoginModel) {
        garanteeMainThread {
            self.loginButton.startLoad()
            self.feedBackLabel?.text = "Verificando dados junto ao CAD"
            self.feedBackLabel?.startBlink()
        }
        let containerDb = UserDefaults(suiteName: "serpro_data")
        let cpf = containerDb?.string(forKey: "cpf") ?? ""
        let identitySecret = ACEnviroment.shared.identitySecret
        let identitySalt = ACEnviroment.shared.identitySalt
        do {
            let identity = try cpf.hmacSHA256(secret: identitySecret, salt: identitySalt)
            containerDb?.set(identity, forKey: "identity")
        } catch {
            logger.error("Não foi possível gerar o header identity.")
        }
        self.model = model
        let env = ACEnviroment.shared
        let platform = SBPlatformDestination(appID: env.logApppId, appSecret: env.logAppSecret, encryptionKey: env.logEncryptionKey)
        platform.minLevel = .verbose
        platform.showNSLog = false
        platform.analyticsUserName = model.usuario?.nome ?? UUID().uuidString

        SwiftyBeaver.addDestination(platform)
        SwiftyBeaver.addDestination(ConsoleDestination())
        SwiftyBeaver.info("Login efetuado com sucesso")
        self.cadService.setUserRoles(model.usuario?.roles ?? [])
        SwiftyBeaver.info("Carregando estados e municípios")
        loadStates {
            SwiftyBeaver.info("Estados e municípios completamente carregados")
            self.checkCadResource(model: model)
        }
        loadDocuments()
        loadExternalSettings()
    }

    private func checkCadResource(model: LoginModel) {
        self.cadService.checkIfIsCadResource { [weak self] result in
            switch result {
            case .success(let cadResource):
                self?.cadNotificationManager.registerForPushNotifications()
                if cadResource?.resource.activeTeam != nil {
                    self?.initRealTimeTracking()
                }
                if cadResource != nil {
                    self?.dispatchService.populateStatuses {
                        self?.initTabBarController(model: model, cadResource: cadResource)
                    }
                } else {
                    self?.initTabBarController(model: model, cadResource: cadResource)
                }
                self?.domainsService.loadNaturesGroups()
                self?.occurrenceService.populateDispatchReleaseReasons()
                if let token = UserDefaults.standard.string(forKey: "apns-token") {
                    CadNotificationService.shared.registerDevice(token: token) { error in
                        if let error = error {
                            self?.logger.error(error.localizedDescription)
                        }
                    }
                }
            case .failure(let error as NSError):
                self?.handleLoginError(error)
            }
        }
    }

    private func handleLoginError(_ error: NSError) {
        garanteeMainThread {
            self.loginButton.stopLoad()
            self.loginButton.isHidden = true
            self.loginButtonHeight?.constant = 0
            self.continueWithoutCadBtn.isHidden = false
            self.feedBackLabel?.stopBlink()
            self.feedBackLabel?.text = ""
            if !error.domain.isEmpty {
                self.feedBackLabel?.text = error.domain
            } else {
                self.feedBackLabel?.text = error.localizedDescription
            }
        }
    }

    internal func initTabBarController(model: LoginModel, cadResource: CadResource?) {
        ModuleService.clearAll()
        ModuleService.register(module: VehicleModule())
        ModuleService.register(module: WarrantModule())
        ModuleService.register(module: OcurencyBulletinModule())
        ModuleService.register(module: DriverModule())

        if cadResource != nil {
            ModuleService.register(module: CadModule())
        }

        garanteeMainThread { [unowned self] in
            self.clearError()

            let tokenService = TokenService()
            tokenService.saveAllToken(model)
            UserService.shared.setCurrentUser( User(with: model) )
            self.loginDelegate?.didFinished(with: model)

            self.loginButton.stopLoad()
            self.feedBackLabel?.stopBlink()
            self.feedBackLabel?.text = ""

            let tabItens = self.buildTabControllers(cadResource: cadResource)
            let tabBarController = TabBarController(with: tabItens, cadResource: cadResource)
            tabBarController.modalPresentationStyle = .fullScreen
            self.present(tabBarController, animated: true, completion: nil)
        }
    }

    private func loadDocuments() {
        WarrantDocumentService().loadAll { (result) in
            switch result {
            case .success:
                self.logger.debug("Documentos carregados com sucesso")
            case .failure(let error):
                SwiftyBeaver.error(error.localizedDescription)
            }
        }
    }

    private func loadExternalSettings() {
        externalSettings.fetchSettings { (error: Error?) in
            print(error)
        }
    }

    private func initRealTimeTracking() {
        if LocationService.status.isAuthorized && cadService.hasActiveTeam() && cadService.hasStartedService() {
            locationService.startUpdatingLocation()
            trackingService.scheduleSendingUserLocation()
        }
    }

    func didReturnAppName() -> String { ACEnviroment.shared.appName }

    func didReturnAppVersion() -> String { ACEnviroment.shared.appVersion }

    func didReturnAppServerKey() -> String { ACEnviroment.shared.appServerKey }

    func didReturnApp() -> String { ACEnviroment.shared.app }

    func didReturnSystemInitials() -> String { ACEnviroment.shared.systemInitials }

    func present(viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }

    private func buildTabControllers(cadResource: CadResource?) -> [AppTabItens] {
        var itens = [AppTabItens]()

        let homeNavigation = NavigationController(navigationBarClass: nil, toolbarClass: CustomToolBar.self)
        homeNavigation.viewControllers = [HomeViewController(cadResource: cadResource)]
        itens.append( .init(title: "Início", icon: UIImage(systemName: "house"), badge: 0, controller: homeNavigation ))

        if cadResource != nil {
            let realTimeNavigation = NavigationController(navigationBarClass: nil, toolbarClass: CustomToolBar.self)
            let realTimeController = RealTimeViewController()
            realTimeNavigation.viewControllers = [realTimeController]
            itens.append(.init(title: "Tempo Real", icon: UIImage(systemName: "map.fill"), badge: 0, controller: realTimeNavigation))

            let teamNavigation = NavigationController(navigationBarClass: nil, toolbarClass: CustomToolBar.self)
            let teamsController: UIViewController = TeamViewController()
            teamNavigation.viewControllers = [teamsController]
            itens.append(.init(title: "Equipes", icon: UIImage(systemName: "person.3.fill"), badge: 0, controller: teamNavigation))
        }

        let settingsNavigation = NavigationController(navigationBarClass: nil, toolbarClass: CustomToolBar.self)
        let settings = SettingsViewController(style: .insetGrouped)
        settingsNavigation.viewControllers = [ settings ]
        itens.append( .init(title: "Configurações", icon: UIImage(systemName: "gear"), badge: 0, controller: settingsNavigation))

        return itens
    }
}
