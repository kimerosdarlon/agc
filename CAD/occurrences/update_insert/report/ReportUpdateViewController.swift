//
//  OccurrenceReportUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 21/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import Combine

class ReportUpdateViewController: OccurrenceUpdateViewController<ReportUpdate> {
    private let cacheStorageKey = "cached_occurrence_report"

    private let occurrenceId: UUID
    private let initialReport: String
    private var reportUpdate: ReportUpdate

    private let reportField = TextAreaFieldComponent(label: "Descreva o relato aqui").enableAutoLayout()

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    private var subscriptions = Set<AnyCancellable>()

    init(initialReport: String, teamId: UUID, occurrenceId: UUID) {
        self.occurrenceId = occurrenceId
        self.initialReport = initialReport
        self.reportUpdate = ReportUpdate(teamId: teamId, report: initialReport)
        super.init(model: reportUpdate, name: "Relato", version: -1, canDelete: false)

        let resportSubject = reportField.getSubject()
        if let storedReport = getStoredReport() {
            resportSubject?.send(storedReport)
        } else {
            resportSubject?.send(initialReport)
        }
        resportSubject?.sink(receiveValue: { newValue in
            guard let newValue = newValue else { return }
            self.storeReportInCache(newValue)
            self.reportUpdate.report = newValue
        }).store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        container.addSubview(reportField)
        reportField
            .top(mutiplier: 1)
            .width(container.widthAnchor, multiplier: 0.95)
            .centerX()
    }

    private func storeReportInCache(_ report: String) {
        UserDefaults.standard.set(report, forKey: cacheStorageKey)
    }

    private func getStoredReport() -> String? {
        UserDefaults.standard.string(forKey: cacheStorageKey)
    }

    private func removeCache() {
        UserDefaults.standard.removeObject(forKey: cacheStorageKey)
    }

    override func didSave() {
        startLoading()
        occurrenceService.update(occurrenceId: occurrenceId, report: reportUpdate) { error in
            garanteeMainThread {
                self.stopLoading()
                if let error = error as NSError? {
                    if error.code == 100 || error.code > 500 {
                        self.showErrorAlert(
                            title: "Sem acesso à internet",
                            message: "Seu relato foi salvo como rascunho e você pode tentar enviá-lo novamente mais tarde."
                        )
                    } else {
                        self.showErrorAlert(title: "Error ao atualizar relato", message: error.domain)
                    }
                } else {
                    self.removeCache()
                    self.showSuccessAlert()
                }
            }
        }
    }
}
