//
//  CADBackgroundStorage.swift
//  CAD
//
//  Created by Samir Chaves on 04/10/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public class CADBackgroundStorageManager {

    public static let shared = CADBackgroundStorageManager()

    public var currentDispatchStatus: DispatchStatus?
    public var currentDispatchedOccurrence: OccurrencePushNotification?
    public var currentDispatchReleased: Bool?
}
