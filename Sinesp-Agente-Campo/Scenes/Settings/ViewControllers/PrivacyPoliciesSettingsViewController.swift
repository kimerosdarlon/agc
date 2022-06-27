//
//  PrivacyPoliciesViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 18/09/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class PrivacyPoliciesSettingsViewController: UIViewController, SettingsOption {

    func settingsTitle() -> String {
        "Políticas de privacidade"
    }

    func settingsSubTitle() -> String {
        ""
    }

    func settingsIcon() -> UIImage {
        UIImage(systemName: "lock")!
    }

    func accesoryView() -> UIView? {
        nil
    }

    func shouldPresent() -> Bool {
        false
    }

    func runAction(in viewController: UIViewController) {
        let url = URL(string: ACEnviroment.shared.privacyPoliciesHost)!
        let app = UIApplication.shared
        if app.canOpenURL(url) {
            app.open(url, options: [:], completionHandler: nil)
        }
    }
}
