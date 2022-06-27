//
//  CadLocationBasedNotificationManager.swift
//  CAD
//
//  Created by Samir Chaves on 03/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import CoreLocation
import Logger
import UserNotifications
import AgenteDeCampoCommon

public class CadLocationBasedNotificationManager: NSObject {
    private typealias Category = CadNotificationManager.Category

    public static let shared = CadLocationBasedNotificationManager()

    private var locationManager = CLLocationManager()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let logger = Logger.forClass(CadLocationBasedNotificationManager.self)
    private var automaticUpdateTask: DispatchWorkItem?

    @DispatchServiceInject
    private var dispatchService: DispatchService

    @CadServiceInject
    private var cadService: CadService

    private var currentMonitoredTask: String?

    public override init() {
        super.init()
        notificationCenter.removeAllPendingNotificationRequests()
        locationManager.delegate = self

        currentMonitoredTask = UserDefaults.standard.string(forKey: "monitored-task")
        if let currentMonitoredTask = currentMonitoredTask {
            if currentMonitoredTask == "displacement" {
                setDisplacementTask()
            } else if currentMonitoredTask == "arrival" {
                setArrivalTask()
            }
        }
    }

    private func setDisplacementTask() {
        automaticUpdateTask?.cancel()
        automaticUpdateTask = DispatchWorkItem {
            self.changeDispatchStatus(to: DispatchStatusCode.moving) {
                garanteeMainThread {
                    NotificationCenter.default.post(name: .cadDispatchDidUpdate, object: nil, userInfo: [
                        "status": DispatchStatus.moving as Any
                    ])
                }
            }

            let userDefaults = UserDefaults.standard
            let latitude = userDefaults.double(forKey: "cad-dispatched-occurrence-lat")
            let longitude = userDefaults.double(forKey: "cad-dispatched-occurrence-lng")
            let radius = userDefaults.integer(forKey: "realtime-settings-radius")
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            self.locationManager.monitoredRegions.forEach { self.locationManager.stopMonitoring(for: $0) }
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.registerForEnterInCircularRegion(center: center, radius: CLLocationDistance(radius))
        }
    }

    private func setArrivalTask() {
        automaticUpdateTask?.cancel()
        automaticUpdateTask = DispatchWorkItem {
            self.changeDispatchStatus(to: DispatchStatusCode.arrived) {
                garanteeMainThread {
                    NotificationCenter.default.post(name: .cadDispatchDidUpdate, object: nil, userInfo: [
                        "status": DispatchStatus.arrived as Any
                    ])
                }
            }
        }
    }

    public func cancelScheduledStatusUpdates() {
        automaticUpdateTask?.cancel()
    }

    private func isMonitoring(regionWithCenter center: CLLocationCoordinate2D, identifier: String) -> Bool {
        let wrappedMonitoredRegion = locationManager.monitoredRegions.first(
            where: { $0.identifier == identifier }
        )
        if let monitoredRegion = wrappedMonitoredRegion as? CLCircularRegion,
           (monitoredRegion.center.latitude - center.latitude) < 0.00001,
           (monitoredRegion.center.longitude - center.longitude) < 0.00001 {
            return true
        }
        return false
    }

    public func registerForLeaveCircularRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let categoryIdentifier = Category.displacementDetected.rawValue
        let regionIdentifier = "userCircularRegion"

        UserDefaults.standard.set("displacement", forKey: "monitored-task")

        let content = UNMutableNotificationContent()
        content.title = "Empenho"
        content.body = "Verificamos que sua localização mudou. Iremos alterar seus status para deslocamento automaticamente."
        content.categoryIdentifier = categoryIdentifier
        content.sound = .default

        let region = CLCircularRegion(center: center, radius: radius, identifier: regionIdentifier)
        region.notifyOnEntry = false
        region.notifyOnExit = true
        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)

        locationManager.startMonitoring(for: region)

        let request = UNNotificationRequest(identifier: "leaveCircularRegionNotification", content: content, trigger: locationTrigger)

        notificationCenter.add(request) { error in
            self.logger.error(error.debugDescription)
        }
        setDisplacementTask()
    }

    public func registerForEnterInCircularRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let regionIdentifier = "occurrenceCircularRegion"
        let region = CLCircularRegion(center: center, radius: radius, identifier: regionIdentifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false

        locationManager.startMonitoring(for: region)

        UserDefaults.standard.set("arrival", forKey: "monitored-task")

        let categoryIdentifier = Category.arrivingDetected.rawValue

        let content = UNMutableNotificationContent()
        content.title = "Empenho"
        content.body = "Verificamos que sua equipe CHEGOU AO LOCAL da ocorrência. Atualize seu status!"
        content.categoryIdentifier = categoryIdentifier
        content.sound = .default

        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)

        let request = UNNotificationRequest(identifier: "enterInCircularRegionNotification", content: content, trigger: locationTrigger)

        notificationCenter.add(request) { error in
            self.logger.error(error.debugDescription)
        }
        setArrivalTask()
    }

    public func removeAllDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        locationManager.monitoredRegions.forEach { region in
            self.locationManager.stopMonitoring(for: region)
        }
    }
}

extension CadLocationBasedNotificationManager: CLLocationManagerDelegate {
    // This function keeps the app's process alive periodically overriding a value in UserDefaults storage
    func asyncAfter(deadline: DispatchTime, completion: @escaping () -> Void) {
        let minimalInterval = 2
        let distanceToNow = deadline.distance(to: .now())
        var distanceInSeconds = 0.0
        switch distanceToNow {
        case .seconds(let distance):
            distanceInSeconds = Double(distance)
        case .milliseconds(let distance):
            distanceInSeconds = Double(distance) * 1e-3
        case .microseconds(let distance):
            distanceInSeconds = Double(distance) * 1e-6
        case .nanoseconds(let distance):
            distanceInSeconds = Double(distance) * 1e-9
        case .never:
            distanceInSeconds = 0
        @unknown default:
            distanceInSeconds = 0
        }
        if abs(distanceInSeconds) < Double(minimalInterval) {
            completion()
        } else {
            UserDefaults.standard.set("keep for \(abs(distanceInSeconds))", forKey: "not-running-app-execution")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(minimalInterval)) {
                if !UserDefaults.standard.bool(forKey: "status-updates-cancelled") {
                    self.asyncAfter(deadline: deadline, completion: completion)
                }
            }
        }
    }
    
    func changeDispatchStatus(to newStatus: DispatchStatusCode, completion: @escaping () -> Void) {
        let userDefaults = UserDefaults.standard
        guard let teamId = userDefaults.string(forKey: "cad-active-team-id").flatMap({ UUID(uuidString: $0) }),
              let occurrenceId = userDefaults.string(forKey: "cad-dispatched-occurrence-id").flatMap({ UUID(uuidString: $0) }) else {
            return
        }
        self.dispatchService.updateStatus(of: teamId, in: occurrenceId, to: newStatus, completion: { error in
            if error == nil {
                completion()
            }
        })
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let task = automaticUpdateTask, region.identifier == "userCircularRegion" {
            DispatchQueue.global().asyncAfter(deadline: .now() + 10, execute: task)
            task.wait()
            automaticUpdateTask = nil
            locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let task = automaticUpdateTask, region.identifier == "occurrenceCircularRegion" {
            DispatchQueue.global().asyncAfter(deadline: .now() + 10, execute: task)
            task.wait()
            automaticUpdateTask = nil
            locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
        }
    }
}
