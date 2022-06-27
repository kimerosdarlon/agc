//
//  Notification+extension.swift
//  CAD
//
//  Created by Samir Chaves on 02/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public extension Notification.Name {
    static let cadResourceWillChange = Notification.Name.init("cadResourceWillChange")
    static let cadResourceDidChange = Notification.Name.init("cadResourceDidChange")
    static let cadTeamDidDispatch = Notification.Name.init("cadTeamDidDispatch")
    static let cadDispatchDidUpdate = Notification.Name.init("cadDispatchDidUpdate")
    static let cadDispatchedOccurrenceDidUpdate = Notification.Name.init("cadDispatchedOccurrenceDidUpdate")
    static let cadDispatchShouldUpdate = Notification.Name.init("cadDispatchShouldUpdate")
    static let cadTeamDidFinishDispatch = Notification.Name.init("cadTeamDidFinishDispatch")
    static let cadDidDispatchedOccurrenceLoad = Notification.Name.init("cadDidDispatchedOccurrenceLoad")
    static let cadDidDispatchedOccurrenceFocus = Notification.Name.init("cadDidDispatchedOccurrenceFocus")
    static let cadCheckForMoving = Notification.Name.init("cadCheckForMoving")
    static let cadCheckForArrive = Notification.Name.init("cadCheckForArrive")
    static let cadCheckForDispatchConfirm = Notification.Name.init("cadCheckForDispatchConfirm")
    static let cadDidReceiveOperationalBreak = Notification.Name.init("cadDidReceiveOperationalBreak")
    static let cadDidDetailAnOccurrence = Notification.Name.init("cadDidDetailAnOccurrence")
    static let cadDidDownloadAnOccurrence = Notification.Name.init("cadDidDownloadAnOccurrence")
    static let cadDidConfirmDispatch = Notification.Name.init("cadDidConfirmDispatch")
    static let cadPreviewDispatchOccurrence = Notification.Name.init("cadPreviewDispatchOccurrence")
}
