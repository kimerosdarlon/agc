//
//  IntermediatePlacePicker.swift
//  CAD
//
//  Created by Samir Chaves on 31/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

protocol IntermediatePlacePickerDelegate: class {
    func didUpdateStatus(to newStatus: DispatchStatus, withIntermediatePlace intermediatePlace: String?, description: String?)
}

public class IntermediatePlacePicker: UIViewController {
    weak var delegate: IntermediatePlacePickerDelegate?
    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    private let nextStatus: DispatchStatus
    private let teamId: UUID
    private let occurrenceId: UUID
    private var selectedPlaceCode: String? {
        return tableView?.selectedPlaceCode
    }
    private var selectedPlaceDescription: String? {
        return tableView?.selectedPlaceDescription
    }

    @DispatchServiceInject
    private var dispatchService: DispatchService

    internal var tableView: IntermediatePlacePickerTableView!

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Confirmar", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .appBlue
        btn.addTarget(self, action: #selector(didConfirm), for: .touchUpInside)
        btn.isEnabled = true
        return btn
    }()

    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Cancelar", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .appBackgroundCell
        btn.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        return btn
    }()

    init(nextStatus: DispatchStatus, teamId: UUID, occurrenceId: UUID, selectedPlaceCode: String?, selectedPlaceDescription: String?) {
        self.nextStatus = nextStatus
        self.teamId = teamId
        self.occurrenceId = occurrenceId

        super.init(nibName: nil, bundle: nil)
        let intermediatePlaces = dispatchService.getIntermediatePlaces()
        self.tableView = IntermediatePlacePickerTableView(places: intermediatePlaces,
                                                          selectedPlaceCode: selectedPlaceCode,
                                                          selectedPlaceDescription: selectedPlaceDescription).enableAutoLayout()
        modalPresentationStyle = .custom

        transitionDelegate = DefaultModalPresentationManager(heightFactor: 0.55, position: .bottom)
        transitioningDelegate = transitionDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didCancel() {
        dismiss(animated: true)
    }

    private func startLoading() {
        sendButton.setTitle("Carregando...", for: .normal)
        sendButton.alpha = 0.65
    }

    private func endLoading() {
        sendButton.setTitle("Confirmar", for: .normal)
        sendButton.alpha = 1
    }

    @objc func didConfirm() {
        let placeCode = self.selectedPlaceCode
        let placeDescription = self.selectedPlaceDescription
        startLoading()
        dispatchService.updateStatus(of: teamId,
                                     in: occurrenceId,
                                     to: nextStatus.raw.code,
                                     intermediatePlace: placeCode,
                                     description: placeDescription) { error in
            garanteeMainThread {
                self.endLoading()
                guard let error = error as NSError? else {
                    self.dismiss(animated: true)
                    self.delegate?.didUpdateStatus(to: self.nextStatus, withIntermediatePlace: placeCode, description: placeDescription)
                    return
                }
                if self.isUnauthorized(error) {
                    self.gotoLogin(error.domain)
                } else {
                    Toast.present(
                        in: self,
                        title: "Não foi possível atualizar o status do empenho",
                        message: error.domain,
                        duration: 3
                    )
                }
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground

        view.addSubview(cancelButton)
        view.addSubview(sendButton)
        view.addSubview(tableView)
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.5),
            sendButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 45),
            sendButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0),

            cancelButton.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.5),
            cancelButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cancelButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            cancelButton.heightAnchor.constraint(equalTo: sendButton.heightAnchor),

            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: sendButton.topAnchor)
        ])
    }
}
