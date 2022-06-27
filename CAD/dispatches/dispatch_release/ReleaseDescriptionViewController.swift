//
//  ReleaseDescriptionViewController.swift
//  CAD
//
//  Created by Samir Chaves on 02/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class ReleaseDescriptionViewController: UIViewController {
    
    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    private let teamId: UUID
    private let occurrenceId: UUID

    private var releaseReasons = [DispatchReleaseReason]()

    private let titleLabel = UILabel.build(withSize: 17, color: .appTitle, text: "Selecione a descrição para liberação do empenho")

    private var reasonsTableView: ReleaseDescriptionPickerTableView!

    private let cancelButton: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        btn.backgroundColor = .clear
        btn.setTitle("Cancelar", for: .normal)
        btn.addTarget(self, action: #selector(didTapInCancelBtn), for: .touchUpInside)
        return btn
    }()

    private let nextButton: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        btn.backgroundColor = .appBlue
        btn.setTitle("Próximo", for: .normal)
        let image = UIImage(systemName: "chevron.right")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(didTapInNextBtn), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -10)
        btn.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        btn.semanticContentAttribute = .forceRightToLeft
        return btn
    }()

    init(teamId: UUID, occurrenceId: UUID) {
        self.teamId = teamId
        self.occurrenceId = occurrenceId
        super.init(nibName: nil, bundle: nil)
        releaseReasons = occurrenceService.getDispatchReleaseReasons()
        reasonsTableView = ReleaseDescriptionPickerTableView(reasons: releaseReasons).enableAutoLayout()
        title = "Liberar empenho"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {        
        view.backgroundColor = .appBackground

        view.addSubview(reasonsTableView)
        view.addSubview(cancelButton)
        view.addSubview(nextButton)
        view.addSubview(titleLabel)

        cancelButton.width(90).height(40)
        nextButton.width(120).height(40)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),

            reasonsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            reasonsTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            reasonsTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            reasonsTableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -15),

            cancelButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
            cancelButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),

            nextButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
            nextButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15)
        ])
    }

    @objc private func didTapInCancelBtn() {
        navigationController?.dismiss(animated: true)
    }

    @objc private func didTapInNextBtn() {
        guard let selectedReason = reasonsTableView.selectedReason else { return }
        let finishReasonController = FinishReasonViewController(teamId: teamId, occurrenceId: occurrenceId,
                                                                selectedReleaseReason: selectedReason,
                                                                finishReasons: selectedReason.finishReasons)
        navigationController?.pushViewController(finishReasonController, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.barTintColor = .clear
    }
}
