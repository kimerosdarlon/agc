//
//  AppDelegate.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 13/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Logger
import UIKit
import IQKeyboardManagerSwift
import AgenteDeCampoCommon
import CoreDataModels
import UserNotifications
import DeviceCheck
import CoreLocation
import CAD

@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {

    var window: UIWindow?
    private var rootViewController: UIViewController?

    private lazy var logger = Logger.forClass(Self.self)

    @BulletimDocumentServiceInject
    private var bulletimService: BulletimDocumentService

    private var cadLocationBasedNotificationManager: CadLocationBasedNotificationManager?

    func applicationDidBecomeActive(_ application: UIApplication) {
        if rootViewController == nil {
            bulletimService.loadAll(completion: { _ in })
            self.rootViewController = LoginViewController()
            window!.rootViewController = rootViewController
            window!.makeKeyAndVisible()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        cadLocationBasedNotificationManager = CadLocationBasedNotificationManager.shared

        IQKeyboardManager.shared.enable = true
        // Logger.addDestination(destination: LoggerConsoleDestination(level: .debug))
        UNUserNotificationCenter.current().delegate = self
        if !UserDefaults.standard.bool(forKey: "recent_was_deleted") {
            RecentsDataSource().clearAll()
            UserDefaults.standard.set(true, forKey: "recent_was_deleted")
        }
        let frame = UIScreen.main.bounds
        self.window = UIWindow(frame: frame)

        if UIApplication.shared.applicationState != .background {
            self.rootViewController = LoginViewController()
            window!.rootViewController = rootViewController
            window!.makeKeyAndVisible()
        }

        let themeString = UserDefaults.standard.string(forKey: "theme")
        let theme = themeString.flatMap { Theme.init(rawValue: $0) }
        let style = theme?.style
        style.map { styleUnwrapped in
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = styleUnwrapped
            }
        }

        return true
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? [String: AnyObject],
           let category = aps["category"] as? String,
           let payload = aps["payload"] as? [String: Any],
           let cadCategory = CadNotificationManager.Category(rawValue: category) {
            CadBackgroundUpdateManager.shared.didReceiveNotification(category: cadCategory,
                                                                     payload: payload,
                                                                     completion: completionHandler)
        } else {
            completionHandler(.noData)
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        print("============== Device Token APNS ==============")
        print(deviceToken.base64EncodedString())
        print("===============================================")

        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()

        UserDefaults.standard.set(token, forKey: "apns-token")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let aps = response.notification.request.content.userInfo["aps"] as? [String: AnyObject],
           let payload = aps["payload"] as? [String: Any] {
            CadNotificationManager.shared.didReceiveResponse(actionIdentifier: response.actionIdentifier,
                                                             categoryIdentifier: response.notification.request.content.categoryIdentifier,
                                                             payload: payload,
                                                             completionHandler: completionHandler)
        } else {
            CadNotificationManager.shared.didReceiveResponse(actionIdentifier: response.actionIdentifier,
                                                             categoryIdentifier: response.notification.request.content.categoryIdentifier,
                                                             completionHandler: completionHandler)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let info = notification.request.content.userInfo as? [String: AnyObject] {
            if let aps = info["aps"] as? [String: AnyObject],
               let category = aps["category"] as? String {
                if category == "AppVersion" {
                    AppVersion.updateBadge(hasUpdate: true)
                    NotificationCenter.default.post(name: .updateBadgeCount, object: nil)
                }

                if let payload = aps["payload"] as? [String: Any] {
                    CadNotificationManager.shared.willPresentNotification(category: category, payload: payload)
                }
            }
        }

        completionHandler([.alert, .sound])
    }
}
