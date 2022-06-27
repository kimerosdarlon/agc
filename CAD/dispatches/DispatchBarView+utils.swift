//
//  DispatcheBarView+utils.swift
//  CAD
//
//  Created by Samir Chaves on 28/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

extension DispatchBarView {
    internal func updateDispatch(nextStatus: DispatchStatus, inBackground: Bool = false) {
        guard let currentTeamId = self.currentDispatch?.team.id,
              let currentOccurrence = self.currentOccurrenceDetails else { return }

        if !inBackground {
            self.statusBtn.startLoading()
        }
        self.dispatchService.updateStatus(of: currentTeamId,
                                          in: currentOccurrence.occurrenceId,
                                          to: nextStatus.raw.code) { error in
            if error == nil {
                self.bgStorage.currentDispatchStatus = nextStatus
            }

            if !inBackground {
                garanteeMainThread {
                    self.statusBtn.endLoading()
                    guard let error = error as NSError? else {
                        self.setCurrentStatus(nextStatus)
                        return
                    }

                    if self.parentViewController.isUnauthorized(error) {
                        self.parentViewController.gotoLogin(error.domain)
                    } else {
                        Toast.present(
                            in: self.parentViewController,
                            title: "Não foi possível atualizar o status do empenho. Tente novamente.",
                            message: error.domain,
                            duration: 3
                        )
                    }
                }
            }
        }
    }

    func didConfirmDispatchUpdate() {
        guard let nextStatus: DispatchStatus = currentStatus?.next,
              let currentTeamId = self.currentDispatch?.team.id,
              let currentOccurrence = self.currentOccurrenceDetails else { return }
        if nextStatus.raw.requiresIntermediatePlace {
            let intermediatePlacePicker = IntermediatePlacePicker(
                nextStatus: nextStatus,
                teamId: currentTeamId,
                occurrenceId: currentOccurrence.occurrenceId,
                selectedPlaceCode: previousIntermediatePlaceCode,
                selectedPlaceDescription: previousIntermediatePlaceDescription
            )
            intermediatePlacePicker.delegate = self
            self.parentViewController.present(intermediatePlacePicker, animated: true)
        } else {
            self.updateDispatch(nextStatus: nextStatus)
        }
    }

    func didUpdateDispatch() {
        guard let nextStatus: DispatchStatus = currentStatus?.next else { return }
        let message = "Tem certeza que deseja atualizar o status desse empenho para \(nextStatus.raw.description)?"
        let alert = UIAlertController(title: "Atualizar empenho", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Atualizar", style: .default) { _ in
            self.didConfirmDispatchUpdate()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        parentViewController.present(alert, animated: true, completion: nil)
    }

    func showDownloadModal() {
        guard let currentOccurrence = self.currentOccurrenceDetails else { return }
        let downloadModal = OccurrenceDownloadConfirmModal(occurrenceId: currentOccurrence.occurrenceId,
                                                           fileName: currentOccurrence.generalInfo.protocol)
        downloadModal.delegate = self
        parentViewController.present(downloadModal, animated: true)
    }

    private func didConfirmReleaseDispatch() {
        guard let currentTeamId = self.currentDispatch?.team.id else { return }
        guard let currentOccurrence = self.currentOccurrenceDetails else { return }

        let releaseCmd = DispatchReleaseCmd(category: nil, reason: nil, description: nil, online: true)
        dispatchService.release(of: currentTeamId, in: currentOccurrence.occurrenceId, command: releaseCmd) { error in
            garanteeMainThread {
                self.statusBtn.endLoading()
                guard let error = error as NSError? else {
                    self.cadService.refreshResource { _ in
                        garanteeMainThread {
                            NotificationCenter.default.post(name: .cadTeamDidFinishDispatch, object: nil)
                            let successAlert = SuccessViewController(feedbackText: "Sua equipe foi liberada com sucesso!",
                                                                     backgroundColor: .appBlue)
                            successAlert.showModal(self.parentViewController, duration: 1.5) {
                                successAlert.dismiss(animated: true)
                                self.bgStorage.currentDispatchedOccurrence = nil
                                self.showDownloadModal()
                            }
                        }
                    }
                    return
                }
                if self.parentViewController.isUnauthorized(error) {
                    self.parentViewController.gotoLogin(error.domain)
                } else if error.code == 422 {
                    let dispatchReleaseNavigation = DispatchReleaseNavigationController(teamId: currentTeamId, occurrenceId: currentOccurrence.occurrenceId)
                    self.parentViewController.present(dispatchReleaseNavigation, animated: true)
                } else {
                    Toast.present(
                        in: self.parentViewController,
                        title: "Não foi possível atualizar o status do empenho",
                        message: error.domain,
                        duration: 3
                    )
                }
            }
        }
    }

    func didReleaseDispatch() {
        let message = "Tem certeza que deseja encerrar o empenho atual?"
        let alert = UIAlertController(title: "Encerrar empenho", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Encerrar", style: .destructive) { _ in
            self.didConfirmReleaseDispatch()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        parentViewController.present(alert, animated: true, completion: nil)
    }

    @objc internal func handleOccurrenceViewLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            if currentOccurrenceDetails != nil {
                feedbackGenerator.impactOccurred()
                showPreviewModal()
            }
        }
    }

    @objc internal func didUpdateOccurrence(_ notification: Notification) {
        if let updatedOccurrenceId = notification.userInfo?["occurrenceId"] as? UUID,
           let currentOccurrenceId = currentOccurrenceDetails?.occurrenceId,
           let currentDispatch = currentDispatch,
           let currentDispatchStatusCode = currentDispatchStatusCode,
           updatedOccurrenceId == currentOccurrenceId {
            configure(with: currentOccurrenceId, dispatch: currentDispatch, statusCode: currentDispatchStatusCode)
        }
    }

    @objc internal func didUpdateDispatchStatus(_ notification: Notification) {
        if let newStatus = notification.userInfo?["status"] as? DispatchStatus {
            setCurrentStatus(newStatus)
        }
    }

    @objc internal func shouldUpdateDispatchStatus(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let newStatusStr = userInfo["status"] as? String,
           let newStatusCode = DispatchStatusCode(rawValue: newStatusStr),
           let newStatus = DispatchStatus.getStatusBy(code: newStatusCode) {
            if let inBackground = userInfo["inBackground"] as? Bool, inBackground {
                updateDispatch(nextStatus: newStatus, inBackground: true)
            } else {
                updateDispatch(nextStatus: newStatus)
            }
        }
    }

    @objc internal func showPreviewModal() {
        guard let occurrenceDetails = currentOccurrenceDetails else { return }
        let preview = OccurrencePreviewViewController(occurrence: occurrenceDetails)
        if let presentingViewController = parentViewController.presentingViewController,
           presentingViewController is OccurrencePreviewViewController {
            presentingViewController.dismiss(animated: true, completion: {
                self.parentViewController.present(preview, animated: true)
            })
        } else {
            parentViewController.present(preview, animated: true)
        }
    }
}

extension DispatchBarView: OccurrenceDownloadConfirmDelegate {
    func didDownloadPdf(_ fileUrl: URL) {
        garanteeMainThread {
            let pdfScreen = PDFViewController(pdfURL: fileUrl)
            self.parentViewController.present(pdfScreen, animated: true)
        }
    }
}
