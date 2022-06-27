//
//  CadNotificationViewController.swift
//  CAD
//
//  Created by Samir Chaves on 15/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import AVFoundation

public class CadNotificationUIController {
    private let rootViewController: UIViewController

    @DispatchServiceInject
    private var dispatchService: DispatchService

    private var notificationManage = CadNotificationManager.shared

    private var currentCadResource: CadResource?

    private var audioPlayer: AVAudioPlayer?

    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    public func handleNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleCheckForMoving), name: .cadCheckForMoving, object: nil)
        center.addObserver(self, selector: #selector(handleCheckForArrive), name: .cadCheckForArrive, object: nil)
        center.addObserver(self, selector: #selector(handleNewDispatch), name: .cadTeamDidDispatch, object: nil)
        center.addObserver(self, selector: #selector(cadResourceWillChange(_:)), name: .cadResourceWillChange, object: nil)
        center.addObserver(self, selector: #selector(cadResourceDidChange(_:)), name: .cadResourceDidChange, object: nil)
        center.addObserver(self, selector: #selector(handleCheckForDispatchConfirm), name: .cadCheckForDispatchConfirm, object: nil)
        center.addObserver(self, selector: #selector(handleOperationalBreak), name: .cadDidReceiveOperationalBreak, object: nil)
        center.addObserver(self, selector: #selector(handleDispatchedOccurrenceUpdate), name: .cadDispatchedOccurrenceDidUpdate, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func playSirenSound() {
        guard let url = Bundle.main.url(forResource: "sirene_agc", withExtension: "") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = audioPlayer else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    @objc private func cadResourceWillChange(_ notification: Notification) {
        if let cadResource = notification.userInfo?["resource"] as? CadResource? {
            currentCadResource = cadResource
        }
    }

    @objc private func cadResourceDidChange(_ notification: Notification) {
        if let wrappedCadResource = notification.userInfo?["resource"] as? CadResource?,
           let cadResource = wrappedCadResource,
           let currentCadResource = currentCadResource,
           let activeTeamId = cadResource.resource.activeTeam {

            let noPreviousDispatch = currentCadResource.dispatches == nil || currentCadResource.dispatches!.isEmpty
            let hasNewDispatch = cadResource.dispatches != nil && !cadResource.dispatches!.isEmpty
            let hasPreviousDispatch = currentCadResource.dispatches != nil && !currentCadResource.dispatches!.isEmpty
            let newDifferentDispatch = currentCadResource.dispatches?.first?.occurrenceId != cadResource.dispatches?.first?.occurrenceId

            if (noPreviousDispatch && hasNewDispatch) || (hasPreviousDispatch && hasNewDispatch && newDifferentDispatch) {
                let dispatch = cadResource.dispatches!.first!
                showDispatchConfirmAlert(teamId: activeTeamId, occurrenceId: dispatch.occurrenceId)
                playSirenSound()
            }
        }
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
            let detailsModal = OccurrenceUpdatesViewController(occurrenceId: occurrenceId, data: occurrenceUpdate)

            detailsModal.delegate = self
            rootViewController.present(detailsModal, animated: true)
        }
    }

    private func confirmDispatch(teamId: UUID, occurrenceId: UUID, showDetails: Bool, completion: @escaping () -> Void) {
        self.dispatchService.confirmDispatch(of: teamId, in: occurrenceId) { error in
            garanteeMainThread {
                if let error = error as NSError? {
                    if self.rootViewController.isUnauthorized(error) {
                        self.rootViewController.gotoLogin(error.domain)
                    } else {
                        self.retryConfirmDispatch(teamId: teamId, occurrenceId: occurrenceId, showDetails: showDetails, error: error)
                    }
                } else {
                    garanteeMainThread {
                        completion()
                    }
                }
            }
        }
    }

    private func retryConfirmDispatch(teamId: UUID, occurrenceId: UUID, showDetails: Bool, error: NSError) {
        guard let topMostController = self.topMostController() else { return }
        let confirmDialog = UIAlertController(
            title: "Confirma o recebimento do empenho?",
            message: "A tentativa anterior falhou: \(error.domain)",
            preferredStyle: .alert
        )
        let doneAction = UIAlertAction(title: "Tentar novamente", style: .default, handler: { _ in
            self.confirmDispatch(teamId: teamId, occurrenceId: occurrenceId, showDetails: showDetails, completion: {
                if showDetails {
                    NotificationCenter.default.post(.init(name: .cadPreviewDispatchOccurrence))
                }
            })
        })
        let cancelAction = UIAlertAction(title: "Cancelar", style: .destructive)
        confirmDialog.addAction(doneAction)
        confirmDialog.addAction(cancelAction)
        topMostController.present(confirmDialog, animated: true)
    }

    public func showDispatchConfirmAlert(teamId: UUID, occurrenceId: UUID) {
        guard let topMostController = self.topMostController() else { return }
        let confirmDialog = UIAlertController(
            title: "Confirma o recebimento do empenho?",
            message: nil,
            preferredStyle: .alert
        )
        let detailsAction = UIAlertAction(title: "Ciente e ir para detalhes", style: .default, handler: { _ in
            self.confirmDispatch(teamId: teamId, occurrenceId: occurrenceId, showDetails: true, completion: {
                NotificationCenter.default.post(.init(name: .cadPreviewDispatchOccurrence))
            })
        })
        let doneAction = UIAlertAction(title: "Ciente", style: .default, handler: { _ in
            self.confirmDispatch(teamId: teamId, occurrenceId: occurrenceId, showDetails: false, completion: { })
        })
        confirmDialog.addAction(doneAction)
        confirmDialog.addAction(detailsAction)
        topMostController.present(confirmDialog, animated: true)
    }

    @objc private func handleNewDispatch(_ notification: Notification) {
        guard UIApplication.shared.applicationState == .active else { return }

        if let occurrence = notification.userInfo?["occurrence"] as? OccurrencePushNotification {
            showDispatchConfirmAlert(
                teamId: occurrence.dispatch.team.id,
                occurrenceId: occurrence.occurrenceDetails.occurrenceId
            )
        }
    }

    @objc private func handleCheckForDispatchConfirm(_ notification: Notification) {
        if let occurrenceId = notification.userInfo?["occurrenceId"] as? UUID,
           let teamId = notification.userInfo?["teamId"] as? UUID {
            showDispatchConfirmAlert(teamId: teamId, occurrenceId: occurrenceId)
        }
    }

    private func topMostController() -> UIViewController? {
        var topController = rootViewController

        while let newTopController = topController.presentedViewController,
              !(newTopController is UIAlertController) {
            topController = newTopController
        }

        return topController
    }
}

extension CadNotificationUIController: OccurrenceUpdateDelegate {
    func goToDetails(occurrence: OccurrenceDetails) {
        NotificationCenter.default.post(name: .cadDidDetailAnOccurrence, object: nil, userInfo: [
            "details": occurrence
        ])
    }
}
