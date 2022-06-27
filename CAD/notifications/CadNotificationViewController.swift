//
//  CadNotificationViewController.swift
//  CAD
//
//  Created by Samir Chaves on 15/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public class CadNotificationUIController {
    private let rootViewController: UIViewController

    @DispatchServiceInject
    private var dispatchService: DispatchService

    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    public func handleNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleCheckForMoving), name: .cadCheckForMoving, object: nil)
        center.addObserver(self, selector: #selector(handleCheckForArrive), name: .cadCheckForArrive, object: nil)
        center.addObserver(self, selector: #selector(handleCheckForDispatchConfirm), name: .cadCheckForDispatchConfirm, object: nil)
        center.addObserver(self, selector: #selector(handleDispatchConfirm), name: .cadDidConfirmDispatch, object: nil)
        center.addObserver(self, selector: #selector(handleOperationalBreak), name: .cadDidReceiveOperationalBreak, object: nil)
        center.addObserver(self, selector: #selector(handleDispatchedOccurrenceUpdate), name: .cadDispatchedOccurrenceDidUpdate, object: nil)
    }

    @objc private func handleCheckForMoving() {
        let alert = UIAlertController(
            title: "Notamos que sua localização mudou",
            message: "Iremos alterar seu status para deslocamento automaticamente. Caso não esteja, deixe-nos informado.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Não estou em deslocamento", style: .cancel))
        let confirmAction = UIAlertAction(title: "Confirmar atualização", style: .default, handler: { _ in
            NotificationCenter.default.post(name: .cadDispatchShouldUpdate, object: nil, userInfo: [
                "status": DispatchStatusCode.moving.rawValue
            ])
        })
        alert.addAction(confirmAction)
        alert.preferredAction = confirmAction
        rootViewController.present(alert, animated: true)
    }

    @objc private func handleCheckForArrive() {
        let alert = UIAlertController(
            title: "Verificamos que sua equipe chegou ao local da ocorrência",
            message: "Iremos alterar seu status para CHEGADA AO LOCAL automaticamente. Caso não esteja, deixe-nos informado.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Não estou no local", style: .cancel))
        let confirmAction = UIAlertAction(title: "Confirmar atualização", style: .default, handler: { _ in
            NotificationCenter.default.post(name: .cadDispatchShouldUpdate, object: nil, userInfo: [
                "status": DispatchStatusCode.arrived.rawValue
            ])
        })
        alert.addAction(confirmAction)
        alert.preferredAction = confirmAction
        rootViewController.present(alert, animated: true)
    }

    @objc private func handleOperationalBreak(_ notification: Notification) {
        if let operationalBreak = notification.userInfo?["operationalBreak"] as? OperationalBreakPushNotification {
            let detailsModal = OperationalBreakViewController(data: operationalBreak)
            rootViewController.present(detailsModal, animated: true)
        }
    }

    @objc private func handleDispatchedOccurrenceUpdate(_ notification: Notification) {
        if let occurrenceId = notification.userInfo?["occurrenceId"] as? UUID,
           let occurrenceUpdate = notification.userInfo?["occurrenceUpdate"] as? OccurrenceUpdatePushNotification {
            let detailsModal = OccurrenceUpdateViewController(occurrenceId: occurrenceId, data: occurrenceUpdate)

            detailsModal.delegate = self
            rootViewController.present(detailsModal, animated: true)
        }
    }

    @objc private func handleDispatchConfirm(_ notification: Notification) {
        if let occurrenceId = notification.userInfo?["occurrenceId"] as? UUID,
           let teamId = notification.userInfo?["teamId"] as? UUID {
            self.dispatchService.confirmDispatch(of: teamId, in: occurrenceId) { error in
                print(error)
            }
        }
    }

    @objc private func handleCheckForDispatchConfirm(_ notification: Notification) {
        if let occurrenceId = notification.userInfo?["occurrenceId"] as? UUID,
           let teamId = notification.userInfo?["teamId"] as? UUID {
            let confirmDialog = UIAlertController(
                title: "Confirma o recebimento do empenho?",
                message: nil,
                preferredStyle: .alert
            )
            let doneAction = UIAlertAction(title: "Ciente", style: .default, handler: { _ in
                self.dispatchService.confirmDispatch(of: teamId, in: occurrenceId) { error in
                    print(error)
                }
            })
            confirmDialog.addAction(doneAction)
            rootViewController.present(confirmDialog, animated: true)
        }
    }
}

extension CadNotificationUIController: OccurrenceUpdateDelegate {
    func goToDetails(occurrence: OccurrenceDetails) {
        if let tabController = rootViewController as? UITabBarController {
            tabController.selectedIndex = 0
            NotificationCenter.default.post(name: .cadDidDetailAnOccurrence, object: nil, userInfo: [
                "details": occurrence
            ])
        }
    }
}
