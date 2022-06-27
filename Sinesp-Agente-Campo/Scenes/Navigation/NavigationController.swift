//
//  HomeViewController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 22/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .appCellLabel
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.appTitle]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.appTitle]
        appearance.backgroundColor = .appBackground
        appearance.shadowColor = .clear
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        NotificationCenter.default.addObserver(self, selector: #selector(handleNavigation(notification:)), name: .actionNavigation, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    @objc
    private func handleNavigation( notification: Notification ) {
        if let controller = notification.userInfo?["viewController"] as? UIViewController {
            pushViewController(controller, animated: true)
        }
    }
}
