//
//  UserPreferences.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 23/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public enum Theme: String, CaseIterable {
    case dark = "Modo noturno"
    case white = "Modo claro"
    case system = "Definido pelo sistema"

    public var style: UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        case .white:
            return .light
        case .system:
            return UIUserInterfaceStyle.unspecified
        }
    }

    public var barStyle: UIStatusBarStyle {
        switch self {
        case .dark:
            return .darkContent
        case .white:
            return .lightContent
        case .system:
            return .default
        }
    }
}

public class UserStylePreferences: UITableViewController {

    public static var theme: Theme {
        get {
            guard let themeString = UserDefaults.standard.string(forKey: "theme") else {
                return .dark
            }
            return Theme.init(rawValue: themeString) ?? .dark
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "theme")
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .appBackground
        title = settingsTitle()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Theme.allCases.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let cellTheme = Theme.allCases[indexPath.item]
        cell.textLabel?.text = cellTheme.rawValue
        cell.backgroundColor = .appBackgroundCell
        cell.textLabel?.textColor = .appCellLabel
        if cellTheme == UserStylePreferences.theme {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UserStylePreferences.theme = Theme.allCases[indexPath.item]
        let style = UserStylePreferences.theme.style
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = style
        view.overrideUserInterfaceStyle = style
        navigationController?.view.overrideUserInterfaceStyle = style
        tabBarController?.view.overrideUserInterfaceStyle = style
        setNeedsStatusBarAppearanceUpdate()
        tableView.reloadData()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension UserStylePreferences: SettingsOption {

    public func settingsTitle() -> String {
        return "Aparência"
    }

    public func settingsSubTitle() -> String {
        return "modifique a aparência"
    }

    public func settingsIcon() -> UIImage {
        return UIImage(systemName: "circle.lefthalf.fill")!
    }

    public func accesoryView() -> UIView? {
        return nil
    }
}
