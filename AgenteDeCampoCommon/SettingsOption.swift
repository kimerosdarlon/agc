//
//  File.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 23/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public protocol SettingsOption {
    func settingsTitle() -> String
    func settingsSubTitle() -> String
    func settingsIcon() -> UIImage
    func accesoryView() -> UIView?
    func shouldPresent() -> Bool
    func runAction(in viewController: UIViewController)
    func getBadge() -> Int
    func enabled() -> Bool
}

public extension SettingsOption {
    func shouldPresent() -> Bool {
        return false
    }

    func runAction(in viewController: UIViewController) {

    }

    func getBadge() -> Int {
        return 0
    }

    func enabled() -> Bool {
        return true
    }
}

public extension SettingsOption where Self: UIViewController {
    func shouldPresent() -> Bool {
        return true
    }
}
