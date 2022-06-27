//
//  NotificationManager.swift
//  CAD
//
//  Created by Samir Chaves on 16/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UserNotifications
import Logger
import CoreLocation
import MapKit
import BackgroundTasks
import Location
import AgenteDeCampoCommon
import RestClient

public class CadNotificationManager: NSObject {
    public enum Category: String, CaseIterable {
        // Remote
        case newDispath = "NEW_DISPATCH"
        case occurrenceUpdate = "OCCURRENCE_UPDATE"
        case operationalBreak = "OPERATIONAL_BREAK"
        case dispatchReleased = "RELEASE_DISPATCH"
        case dispatchUpdate = "DISPATCH_STATUS_UPDATE"

        // Local
        case displacementDetected = "DISPLACEMENT_DETECTED"
        case arrivingDetected = "ARRIVING_DETECTED"
    }

    enum Action: String {
        case cancel = "CANCEL_ACTION"
        case changeStatusToMoving = "CHANGE_STATUS_TO_MOVING"
        case changeStatusToArrivedAtOccurrence = "CHANGE_STATUS_TO_ARRIVED_AT_OCCURRENCE"
        case goToOccurrenceDetails = "GO_TO_OCCURRENCE_DETAILS"
        case confirmDispatch = "CONFIRM_DISPATCH"
    }

    @DispatchServiceInject
    private var dispatchService: DispatchService

    @CadServiceInject
    private var cadService: CadService

    private let notificationCenter = UNUserNotificationCenter.current()

    private let bgStorage = CADBackgroundStorageManager.shared

    private let logger = Logger.forClass(CadNotificationManager.self)

    public static let shared = CadNotificationManager()

    public func registerForPushNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error == nil && granted {
                self.logger.info("Notification permission granted.")
                self.registerNotificationCategories()
            }
        }
    }

    private let newDispatchCategory: UNNotificationCategory = {
        let okAction = UNNotificationAction(
            identifier: Action.confirmDispatch.rawValue,
            title: "Ciente",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        return UNNotificationCategory(
            identifier: Category.newDispath.rawValue,
            actions: [okAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: UNNotificationCategoryOptions(rawValue: 0)
        )
    }()

    private let movingStatusCategory: UNNotificationCategory = {
        let cancelAction = UNNotificationAction(
            identifier: Action.cancel.rawValue,
            title: "Não estou em deslocamento",
            options: .destructive
        )
        let changeAction = UNNotificationAction(
            identifier: Action.changeStatusToMoving.rawValue,
            title: "Confirmar atualização",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        return UNNotificationCategory(
            identifier: Category.displacementDetected.rawValue,
            actions: [changeAction, cancelAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
    }()

    private let arrivedStatusCategory: UNNotificationCategory = {
        let cancelAction = UNNotificationAction(
            identifier: Action.cancel.rawValue,
            title: "Mais tarde",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        let changeAction = UNNotificationAction(
            identifier: Action.changeStatusToArrivedAtOccurrence.rawValue,
            title: "Atualizar agora",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        return UNNotificationCategory(
            identifier: Category.arrivingDetected.rawValue,
            actions: [changeAction, cancelAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
    }()

    private func registerNotificationCategories() {
        notificationCenter.setNotificationCategories(
            [movingStatusCategory, arrivedStatusCategory, newDispatchCategory]
        )
    }

    public func willPresentNotification(category: String, payload: [String: Any]) {
        if let cadCategory = CadNotificationManager.Category(rawValue: category) {
            if cadCategory == .newDispath,
               let occurrenceDict = payload["occurrence"] as? [String: Any],
               let occurrence = OccurrencePushNotification.fromDict(occurrenceDict) {
                NotificationCenter.default.post(name: .cadTeamDidDispatch, object: nil, userInfo: [
                    "occurrence": occurrence
                ])
            } else if cadCategory == .dispatchReleased {
                NotificationCenter.default.post(name: .cadTeamDidFinishDispatch, object: nil)
            } else if cadCategory == .operationalBreak,
                      let opBreakDict = payload["breakInfo"] as? [String: Any],
                      let opBreak = OperationalBreakPushNotification.fromDict(opBreakDict),
                      opBreak.paused {
                NotificationCenter.default.post(name: .cadDidReceiveOperationalBreak, object: nil, userInfo: [
                   "operationalBreak": opBreak
                ])
            } else if cadCategory == .occurrenceUpdate,
                      let occurrenceIdStr = payload["occurrenceId"] as? String,
                      let occurrenceId = UUID(uuidString: occurrenceIdStr),
                      let occurrenceUpdateDict = payload["patch"] as? [String: Any],
                      let occurrenceUpdate = OccurrenceUpdatePushNotification.fromDict(occurrenceUpdateDict) {
                NotificationCenter.default.post(name: .cadDispatchedOccurrenceDidUpdate, object: nil, userInfo: [
                    "occurrenceId": occurrenceId,
                    "occurrenceUpdate": occurrenceUpdate
                ])
            } else if cadCategory == .dispatchUpdate,
                  let statusData = payload["status"] as? [String: Any],
                  let statusCodeStr = statusData["statusCode"] as? String,
                  let statusCode = DispatchStatusCode.init(rawValue: statusCodeStr),
                  let status = DispatchStatus.getStatusBy(code: statusCode) {
                NotificationCenter.default.post(name: .cadDispatchDidUpdate, object: nil, userInfo: [
                    "status": status
                ])
            }
        }
    }

    public func didReceiveResponse(actionIdentifier: String,
                                   categoryIdentifier: String,
                                   payload: [String: Any],
                                   completionHandler: @escaping () -> Void) {
        if actionIdentifier == UNNotificationDefaultActionIdentifier {
            if categoryIdentifier == Category.newDispath.rawValue,
               let occurrenceDict = payload["occurrence"] as? [String: Any],
               let occurrence = OccurrencePushNotification.fromDict(occurrenceDict) {
                NotificationCenter.default.post(name: .cadCheckForDispatchConfirm, object: nil, userInfo: [
                    "occurrenceId": occurrence.occurrenceDetails.occurrenceId,
                    "teamId": occurrence.dispatch.team.id
                ])
            }
            if categoryIdentifier == Category.operationalBreak.rawValue,
               let opBreakDict = payload["breakInfo"] as? [String: Any],
               let opBreak = OperationalBreakPushNotification.fromDict(opBreakDict),
               opBreak.paused {
                NotificationCenter.default.post(name: .cadDidReceiveOperationalBreak, object: nil, userInfo: [
                    "operationalBreak": opBreak
                ])
            }
            if categoryIdentifier == Category.occurrenceUpdate.rawValue,
               let occurrenceIdStr = payload["occurrenceId"] as? String,
               let occurrenceId = UUID(uuidString: occurrenceIdStr),
               let occurrenceUpdateDict = payload["patch"] as? [String: Any],
               let occurrenceUpdate = OccurrenceUpdatePushNotification.fromDict(occurrenceUpdateDict) {
                NotificationCenter.default.post(name: .cadDispatchedOccurrenceDidUpdate, object: nil, userInfo: [
                    "occurrenceId": occurrenceId,
                    "occurrenceUpdate": occurrenceUpdate
                ])
            }
            completionHandler()
        }
        if actionIdentifier == Action.confirmDispatch.rawValue,
           let occurrenceDict = payload["occurrence"] as? [String: Any],
           let occurrence = OccurrencePushNotification.fromDict(occurrenceDict) {
            handleDispatchConfirm(
                of: occurrence.dispatch.team.id,
                in: occurrence.occurrenceDetails.occurrenceId,
                completion: {
                    let userDefaults = UserDefaults.standard
                    let latitude = userDefaults.double(forKey: "cad-dispatched-occurrence-lat")
                    let longitude = userDefaults.double(forKey: "cad-dispatched-occurrence-lng")
                    let radius = userDefaults.integer(forKey: "realtime-settings-radius")
                    let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    CadLocationBasedNotificationManager.shared.registerForLeaveCircularRegion(center: center, radius: CLLocationDistance(radius))
                    completionHandler()
                }
            )
        }
    }

    public func didReceiveResponse(actionIdentifier: String,
                                   categoryIdentifier: String,
                                   completionHandler: @escaping () -> Void) {
        if actionIdentifier == UNNotificationDefaultActionIdentifier {
            if categoryIdentifier == Category.displacementDetected.rawValue {
                NotificationCenter.default.post(name: .cadCheckForMoving, object: nil)
            }
            if categoryIdentifier == Category.arrivingDetected.rawValue {
                NotificationCenter.default.post(name: .cadCheckForArrive, object: nil)
            }
            completionHandler()
        }
        if actionIdentifier == Action.changeStatusToMoving.rawValue {
            NotificationCenter.default.post(name: .cadDispatchShouldUpdate, object: nil, userInfo: [
                "status": DispatchStatusCode.moving.rawValue
            ])
            completionHandler()
        }
        if actionIdentifier == Action.changeStatusToArrivedAtOccurrence.rawValue {
            NotificationCenter.default.post(name: .cadDispatchShouldUpdate, object: nil, userInfo: [
                "status": DispatchStatusCode.arrived.rawValue
            ])
            completionHandler()
        }
        if actionIdentifier == Action.cancel.rawValue {
            if categoryIdentifier == Category.arrivingDetected.rawValue ||
                categoryIdentifier == Category.displacementDetected.rawValue {
                CadLocationBasedNotificationManager.shared.cancelScheduledStatusUpdates()
            }
        }
    }
}

extension CadNotificationManager {
    func handleDispatchConfirm(of teamId: UUID, in occurrenceId: UUID, completion: @escaping () -> Void) {
        dispatchService.confirmDispatch(of: teamId, in: occurrenceId) { _ in
            garanteeMainThread {
                completion()
            }
        }
    }
}
