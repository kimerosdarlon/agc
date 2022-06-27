//
//  OccurrenceDownloadConfirmModal.swift
//  CAD
//
//  Created by Samir Chaves on 29/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import PDFKit
import Combine

protocol OccurrenceDownloadConfirmDelegate: class {
    func didDownloadPdf(_ fileUrl: URL)
}

class OccurrenceDownloadConfirmModal: UIViewController {
    weak var delegate: OccurrenceDownloadConfirmDelegate?

    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView().enableAutoLayout()
        indicator.style = .large
        indicator.backgroundColor = UIColor.appBackground.withAlphaComponent(0.5)
        return indicator
    }()
    private let titleLabel = UILabel.build(withSize: 20, weight: .bold, color: .appTitle, text: "Emissão de Boletim de Atendimento")
    private let descriptionLabel = UILabel.build(
        withSize: 14, alpha: 0.8, color: .appTitle,
        text: "Os campos abaixo são opcionais caso deseje que no boletim seja disponibilizado a área para assinatura do responsável na unidade de recebimento."
    )
    private let unitOwnerField = TextFieldComponent(placeholder: "", label: "Responsável pela unidade").enableAutoLayout()
    private let unitField = TextFieldComponent(placeholder: "", label: "Unidade de recebimento").enableAutoLayout()

    private var canSave = true {
        didSet {
            if canSave {
                saveBtn.alpha = 1
                saveBtn.isUserInteractionEnabled = true
            } else {
                saveBtn.alpha = 0.6
                saveBtn.isUserInteractionEnabled = false
            }
        }
    }

    private let saveBtn: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        btn.setTitle("Salvar", for: .normal)
        btn.setTitleColor(.appBlue, for: .normal)
        btn.addTarget(self, action: #selector(didTapOnSaveBtn), for: .touchUpInside)
        return btn
    }()

    private let cancelBtn: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        btn.setTitle("Cancelar", for: .normal)
        btn.setTitleColor(.appRed, for: .normal)
        btn.addTarget(self, action: #selector(didTapOnCancelBtn), for: .touchUpInside)
        return btn
    }()

    private let occurrenceId: UUID
    private let fileName: String

    private var unitOwner: String?
    private var unit: String?

    private var subscriptions = Set<AnyCancellable>()

    init(occurrenceId: UUID, fileName: String) {
        self.occurrenceId = occurrenceId
        self.fileName = fileName
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitionDelegate = DefaultModalPresentationManager(heightFactor: 0.4, position: .center)
        transitioningDelegate = transitionDelegate

        unitOwnerField.getSubject()?
            .sink(receiveValue: { newUnitOwner in
                self.unitOwner = newUnitOwner.flatMap { $0.isEmpty ? nil : $0 }
                self.checkIfCanSave()
            })
            .store(in: &subscriptions)

        unitField.getSubject()?
            .sink(receiveValue: { newUnit in
                self.unit = newUnit.flatMap { $0.isEmpty ? nil : $0 }
                self.checkIfCanSave()
            })
            .store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func checkIfCanSave() {
        if (unitOwner == nil && unit == nil) || (unitOwner != nil && unit != nil) {
            canSave = true
        } else {
            canSave = false
        }
    }

    @objc private func didTapOnSaveBtn() {
        startLoading()
        occurrenceService.pdf(occurrenceId: occurrenceId,
                              policeChiefName: unitOwner,
                              policeOffice: unit,
                              fileName: fileName) { result in
            switch result {
            case .success(let fileURL):
                garanteeMainThread {
                    self.stopLoading()
                    self.dismiss(animated: true) {
                        self.delegate?.didDownloadPdf(fileURL)
                    }
                }
            case .failure(let error as NSError):
                Toast.present(in: self, message: error.domain)
            }
        }
    }

    @objc private func didTapOnCancelBtn() {
        dismiss(animated: true)
    }

    private func startLoading() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }

    private func stopLoading() {
        loadingIndicator.isHidden = false
        loadingIndicator.stopAnimating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(unitOwnerField)
        view.addSubview(unitField)
        view.addSubview(saveBtn)
        view.addSubview(cancelBtn)
        view.addSubview(loadingIndicator)

        loadingIndicator.fillSuperView()

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            descriptionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),

            unitOwnerField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
            unitOwnerField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            unitOwnerField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),

            unitField.topAnchor.constraint(equalTo: unitOwnerField.bottomAnchor, constant: 15),
            unitField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            unitField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),

            saveBtn.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
            saveBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),

            cancelBtn.centerYAnchor.constraint(equalTo: saveBtn.centerYAnchor),
            cancelBtn.trailingAnchor.constraint(equalTo: saveBtn.leadingAnchor, constant: -25)
        ])
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}
