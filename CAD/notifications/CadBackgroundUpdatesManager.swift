//
//  CadBackgroundUpdatesManager.swift
//  CAD
//
//  Created by Samir Chaves on 02/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import CoreLocation
import UIKit

public class CadBackgroundUpdateManager {

    public static let shared = CadBackgroundUpdateManager()

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    private let bgStorage = CADBackgroundStorageManager.shared

    public func didReceiveNotification(category: CadNotificationManager.Category, payload: [String: Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        if category == .newDispath,
           let occurrenceDict = payload["occurrence"] as? [String: Any],
           let occurrence = OccurrencePushNotification.fromDict(occurrenceDict) {
            bgStorage.currentDispatchedOccurrence = occurrence
            completion(.noData)
        } else if category == .dispatchReleased {
            bgStorage.currentDispatchedOccurrence = nil
            completion(.noData)
        } else if category == .dispatchUpdate,
                  let statusData = payload["status"] as? [String: Any],
                  let statusCodeStr = statusData["statusCode"] as? String,
                  let statusCode = DispatchStatusCode.init(rawValue: statusCodeStr),
                  let status = DispatchStatus.getStatusBy(code: statusCode) {
            bgStorage.currentDispatchStatus = status
            completion(.noData)
        } else if category == .occurrenceUpdate,
                  let occurrenceIdStr = payload["occurrenceId"] as? String,
                  let occurrenceId = UUID(uuidString: occurrenceIdStr),
                  let occurrenceUpdateDict = payload["patch"] as? [String: Any],
                  let occurrenceUpdate = OccurrenceUpdatePushNotification.fromDict(occurrenceUpdateDict) {
            occurrenceService.getOccurrenceById(occurrenceId) { result in
                switch result {
                case .success(let details):
                    if let dispatchOccurrence = self.bgStorage.currentDispatchedOccurrence {
                        self.bgStorage.currentDispatchedOccurrence = details.toPushNotification(dispatch: dispatchOccurrence.dispatch)
                    }

                    completion(.newData)
                case .failure:
                    completion(.failed)
                }
            }
        } else {
            completion(.noData)
        }
    }
}
