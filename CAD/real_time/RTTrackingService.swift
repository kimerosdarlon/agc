//
//  RTTrackingService.swift
//  CAD
//
//  Created by Samir Chaves on 19/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import Location
import CoreLocation
import CoreData
import AgenteDeCampoCommon
import BackgroundTasks

public class RTTrackingService: NSObject, CLLocationManagerDelegate {

    @RealTimeServiceInject
    private var realTimeService: RealTimeService

    @CadServiceInject
    private var cadService: CadService

    private var coreDataContext: NSManagedObjectContext!

    private let locationService = LocationService.shared

    private var settings: RealTimeSettings {
        return ExternalSettingsService.settings.realTime
    }

    public static let shared = RTTrackingService()

    private var lastLocationUpdate: Date?

    override init() {
        super.init()
        coreDataContext = CADPackageDataStack.shared.context
    }

    private var trackTimer: Timer?

    private func fetchStoragedPositions() -> [PositionEventRecord] {
        let records: [PositionEventInput] = (try? coreDataContext.fetch(PositionEventInput.fetchRequest())) ?? []
        return records.map { $0.toRecord() }
    }

    private func cleanStoragedPositions() throws {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PositionEventInput")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        try coreDataContext.execute(deleteRequest)
        try coreDataContext.save()
    }

//        do {
//            try self.cleanStoragedPositions()
//        } catch {
//            _ = try? self.cleanStoragedPositions()
//        }
    private func sendPositionsInBatch(positions: [PositionEventRecord], completion: @escaping () -> Void, retries: Int = 0) {
        realTimeService.batchPublishLocation(positions) { result in
            switch result {
            case .success:
                completion()
            case .failure:
                if retries < 3 {
                    self.sendPositionsInBatch(positions: positions, completion: completion, retries: retries + 1)
                } else {
                    completion()
                }
            }
        }
    }

    private func sendChunckedPositions(chuncks: [[PositionEventRecord]]) {
        guard let piece = chuncks.first else {
            do {
                try cleanStoragedPositions()
            } catch {
                _ = try? cleanStoragedPositions()
            }
            return
        }
        sendPositionsInBatch(positions: piece, completion: {
            let remaining = Array(chuncks[1..<chuncks.count])
            self.sendChunckedPositions(chuncks: remaining)
        })
    }

    private func sendStorageData() {
        let storedPositions = fetchStoragedPositions()
        if !storedPositions.isEmpty {
            let chuckedStoredPositions = storedPositions.chunked(into: 100)
            sendChunckedPositions(chuncks: chuckedStoredPositions)
        }
    }

    @objc
    private func sendCurrentLocation(location: CLLocation, completion: @escaping (Error?) -> Void) {
        realTimeService.publishLocation(location) { (positionEvent, result) in
            switch result {
            case .success:
                self.sendStorageData()
                completion(nil)
            case .failure(let error as NSError):
                if error.code == 422 {
                    self.cadService.refreshResource { error in
                        if let error = error as NSError?, error.code == 401 {
                            NotificationCenter.default.post(name: .userUnauthenticated, object: error as NSError)
                        } else if !self.cadService.hasActiveTeam() {
                            self.locationService.stopUpdatingLocation()
                            self.stopSendingUserLocation()
                        }
                    }
                } else if error.code == 401 {
                    self.locationService.stopUpdatingLocation()
                    self.stopSendingUserLocation()
                } else {
                    let positionInput = PositionEventInput(context: self.coreDataContext)
                    positionInput.accuracy = positionEvent.accuracy
                    positionInput.latitude = positionEvent.latitude
                    positionInput.longitude = positionEvent.longitude
                    positionInput.eventTimestamp = Int64(positionEvent.eventTimestamp)
                    positionInput.teamId = positionEvent.teamId
                    positionInput.deviceId = positionEvent.deviceId

                    do {
                        try self.coreDataContext.save()
                    } catch {
                        try? self.coreDataContext.save()
                    }
                }
                completion(error)
            }
        }
    }

    @objc private func sendCurrentLocation(_ notification: Notification) {
        var timeInterval: TimeInterval = settings.positionCollectionInterval / 1000
        if !cadService.getDispatches().isEmpty {
            timeInterval = settings.dispatchedTeamPositionCollectionInterval / 1000
        }

        if let lastLocation = notification.userInfo?["location"] as? CLLocation {
            if lastLocationUpdate == nil {
                self.sendCurrentLocation(location: lastLocation, completion: { error in
                    if let error = error as NSError?, error.code == 401 {
                        NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                    }
                })
                self.lastLocationUpdate = Date()
            }

            if let lastLocationUpdate = lastLocationUpdate,
               let timeDiff = lastLocationUpdate.difference(to: Date(), [.second]).second,
               Double(timeDiff) >= timeInterval {
                self.sendCurrentLocation(location: lastLocation, completion: { error in
                    if let error = error as NSError?, error.code == 401 {
                        NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                    }
                })
                self.lastLocationUpdate = Date()
            }
        }
    }

    public func scheduleSendingUserLocation() {
        if cadService.getActiveTeam() != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(sendCurrentLocation(_:)), name: .userLocationDidChange, object: nil)
        }
    }

    public func stopSendingUserLocation() {
        NotificationCenter.default.removeObserver(self, name: .userLocationDidChange, object: nil)
    }
}
