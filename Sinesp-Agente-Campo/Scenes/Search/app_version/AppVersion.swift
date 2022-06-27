//
//  AppVersion.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import StoreKit

class AppVersion: NSObject, SettingsOption {

    static let appId = "1513040092"

    func settingsTitle() -> String {
        return "Versão \(AppVersion.currentVersion())"
    }

    func settingsSubTitle() -> String {
        "Nova versão disponível"
    }

    func settingsIcon() -> UIImage {
        return UIImage(systemName: "gear")!
    }

    func accesoryView() -> UIView? {
        return nil
    }

    static func currentVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version).\(build)"
    }

    func getBadge() -> Int {
        return UserDefaults.standard.integer(forKey: "versionCount")
    }

    static private func isUpdateAvailable(currentVersion: String, updatedVersion: String) -> Bool {
        let currentVersionSplit = currentVersion.split(separator: ".")
        let updatedVersionSplit = updatedVersion.split(separator: ".")

        guard let majorCurrentVersion = Int(currentVersionSplit[0]) else { return false }
        guard let minorCurrentVersion = Int(currentVersionSplit[1]) else { return false }
        guard let patchCurrentVersion = Int(currentVersionSplit[2]) else { return false }

        guard let majorLatestVersion = Int(updatedVersionSplit[0]) else { return false }
        guard let minorLatestVersion = Int(updatedVersionSplit[1]) else { return false }
        guard let patchLatestVersion = Int(updatedVersionSplit[2]) else { return false }

        if majorCurrentVersion <= majorLatestVersion {
            if majorCurrentVersion < majorLatestVersion {
                return true
            } else {
                if minorCurrentVersion <= minorLatestVersion {
                    if minorCurrentVersion < minorLatestVersion {
                        return true
                    } else {
                        return patchCurrentVersion < patchLatestVersion
                    }
                }
            }
        }
        return false
    }

    /// Verifica se o aplicativo está desatualizado
    /// - Parameter completion:retorna true se existir atualização e sempre retorna a string com a versão mais recente.
    static func checkIfHasNewVersion(completion: @escaping (Bool, String) -> Void ) {
        #if DEBUG
            let debug = true
        #else
            let debug = false
        #endif
        let updatedVersion = ExternalSettingsService.settings.ios
        let updatedVersionString = "\(updatedVersion.version).\(updatedVersion.build)"
        let currentVersionString = self.currentVersion()

        if debug {
            completion(false, currentVersionString)
            return
        }

        if isUpdateAvailable(currentVersion: currentVersionString, updatedVersion: updatedVersionString) {
            completion(true, updatedVersionString)
        } else {
            completion(false, currentVersionString)
        }
    }

    static func updateBadge(hasUpdate: Bool) {
        let userDefaults = UserDefaults.standard
        let app = UIApplication.shared
        let dontReminderYet = userDefaults.integer(forKey: "versionCount") == 0
        if hasUpdate && dontReminderYet {
            app.applicationIconBadgeNumber += 1
            UserDefaults.standard.set(1, forKey: "versionCount")
        } else if !hasUpdate {
            app.applicationIconBadgeNumber -= 1
            UserDefaults.standard.set(0, forKey: "versionCount")
        }
    }

    static func goToAppStore() {
        guard let customAppURL = URL(string: "itms-apps://itunes.apple.com/us/app/id\(appId)?mt=8") else { return }
        if UIApplication.shared.canOpenURL(customAppURL) {
            UIApplication.shared.open(customAppURL, options: [:], completionHandler: nil)
        }
    }

    func runAction(in viewController: UIViewController) {
        AppVersion.checkIfHasNewVersion { (updateAvailable, _) in
            if updateAvailable {
                self.showUpdateMessage(in: viewController)
            } else {
                self.showCurrentVersionMessage(in: viewController)
            }
        }
    }

    func showUpdateMessage(in viewController: UIViewController) {
        let message = "Atualize agora e aproveite a nova versão disponivel para download na loja"
        let alert = UIAlertController(title: "Atualização disponivel!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "atualizar", style: .default) { (_) in
            DispatchQueue.main.async {
                AppVersion.goToAppStore()
            }
        }
        let cancelAction = UIAlertAction(title: "mais tarde", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    func showCurrentVersionMessage(in viewController: UIViewController) {
        let message = "Seu aplicativo está atualizado, você está usando a última versão disponível"
        let alert = UIAlertController(title: "Tudo certo!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "entendi", style: .default)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
