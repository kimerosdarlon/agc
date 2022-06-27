//
//  TermsAgreementViewController.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 01/10/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class TermsAgreementSettingsViewController: TermsAgreementController, SettingsOption {

    func settingsTitle() -> String {
        "Termo de confidencialidade"
    }

    func settingsSubTitle() -> String {
        ""
    }

    func settingsIcon() -> UIImage {
        UIImage(systemName: "square.and.pencil")!
    }

    func accesoryView() -> UIView? {
        nil
    }
}
