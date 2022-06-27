//
//  FinishReasonViewController.swift
//  CAD
//
//  Created by Samir Chaves on 02/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class FinishReasonViewController: UIViewController {
    private let finishReasons: [FinishReason]
    private let selectedReleaseReason: DispatchReleaseReason

    private let teamId: UUID
    private let occurrenceId: UUID

    private let titleLabel = UILabel.build(withSize: 17, weight: .bold, color: .appTitle)
    private let subtitleLabel = UILabel.build(withSize: 16, color: .appTitle, text: "Selecione o motivo para liberação do empenho")

    private var reasonsTableView: FinishReasonTableView!

    @DispatchServiceInject
    private var dispatchService: DispatchService

    @CadServiceInject
    private var cadService: CadService

    private let backButton: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        btn.backgroundColor = .clear
        btn.setTitle("Voltar", for: .normal)
        btn.addTarget(self, action: #selector(didTapInBackBtn), for: .touchUpInside)
        return btn
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        btn.backgroundColor = .appBlue
        btn.setTitle("Finalizar", for: .normal)
        let image = UIImage(systemName: "chevron.right")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(didTapInNextBtn), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -10)
        btn.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        btn.semanticContentAttribute = .forceRightToLeft
        return btn
    }()

    init(teamId: UUID, occurrenceId: UUID, selectedReleaseReason: DispatchReleaseReason, finishReasons: [FinishReason]) {
        self.teamId = teamId
        self.occurrenceId = occurrenceId
        self.finishReasons = finishReasons
        self.selectedReleaseReason = selectedReleaseReason
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = selectedReleaseReason.description
        reasonsTableView = FinishReasonTableView(reasons: finishReasons).enableAutoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Liberar empenho"

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(reasonsTableView)
        view.addSubview(backButton)
        view.addSubview(sendButton)

        backButton.width(90).height(40)
        sendButton.width(140).height(40)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            subtitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            subtitleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),

            reasonsTableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 25),
            reasonsTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            reasonsTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            reasonsTableView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -15),

            backButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
            backButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),

            sendButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
            sendButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationItem.hidesBackButton = true
    }

    @objc private func didTapInBackBtn() {
        navigationController?.popViewController(animated: true)
    }

    private func startLoading() {
        sendButton.setTitle("Carregando...", for: .normal)
        sendButton.alpha = 0.65
    }

    private func endLoading() {
        sendButton.setTitle("Finalizar", for: .normal)
        sendButton.alpha = 1
    }

    func showDownloadModal() {
        let downloadModal = OccurrenceDownloadConfirmModal(occurrenceId: occurrenceId,
                                                           fileName: occurrenceId.uuidString)
        downloadModal.delegate = self
        parent?.present(downloadModal, animated: true)
    }

    @objc private func didTapInNextBtn() {
        guard let finishCategory = reasonsTableView.selectedReasonCode else { return }
        let releaseCmd = DispatchReleaseCmd(
            category: selectedReleaseReason.code,
            reason: finishCategory,
            description: reasonsTableView.selectedReasonDescription,
            online: true
        )
        startLoading()
        dispatchService.release(of: teamId, in: occurrenceId, command: releaseCmd) { error in
            garanteeMainThread {
                if let error = error as NSError? {
                    if self.isUnauthorized(error) {
                        self.gotoLogin(error.domain)
                    } else {
                        Toast.present(
                            in: self,
                            title: "Não foi possível liberar o empenho",
                            message: error.domain,
                            duration: 3
                        )
                    }
                } else {
                    self.cadService.refreshResource { error in
                        garanteeMainThread {
                            if let error = error as NSError?, self.isUnauthorized(error) {
                                self.gotoLogin(error.domain)
                            } else {
                                self.endLoading()
                                let successAlert = SuccessViewController(feedbackText: "Sua equipe foi liberada com sucesso!",
                                                                         backgroundColor: .appBlue)
                                successAlert.showModal(self, duration: 2) {
                                    self.dismiss(animated: true)
                                    self.showDownloadModal()
                                }
                                NotificationCenter.default.post(name: .cadTeamDidFinishDispatch, object: nil)
                            }
                        }
                    }
                    return
                }
            }
        }
    }
}

extension FinishReasonViewController: OccurrenceDownloadConfirmDelegate {
    func didDownloadPdf(_ fileUrl: URL) {
        garanteeMainThread {
            NotificationCenter.default.post(name: .cadDidDownloadAnOccurrence, object: nil, userInfo: [
                "pdfUrl": fileUrl
            ])
        }
    }
}
