//
//  OccurrenceUpdatesViewController.swift
//  CAD
//
//  Created by Samir Chaves on 17/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

protocol OccurrenceUpdateDelegate: class {
    func goToDetails(occurrence: OccurrenceDetails)
}

class OccurrenceUpdatesViewController: UIViewController {
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    weak var delegate: OccurrenceUpdateDelegate?

    private let detailsBtn: AGCRoundedButton = {
        let btn = AGCRoundedButton(text: "Ver detalhes da ocorrência", loadingText: "").enableAutoLayout()
        btn.addTarget(self, action: #selector(didTapInDetailsBtn), for: .touchUpInside)
        return btn
    }()
    private let closeBtn: UIButton = {
        let btn = UIButton(type: .close)
        btn.enableAutoLayout()
        btn.setTitleColor(.red, for: .normal)
        btn.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        btn.addTarget(self, action: #selector(didTapInCloseBtn), for: .touchUpInside)
        return btn
    }()
    private let titleLabel = UILabel.build(withSize: 17, weight: .bold, color: .appTitle, text: "Atualização da ocorrência empenhada")
    private let updatesContainerView = UIScrollView().enableAutoLayout()
    private let updatesView: UIStackView = {
        let view = UIStackView().enableAutoLayout()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 12
        return view
    }()
    private let occurrenceId: UUID
    private let occurrenceUpdate: OccurrenceUpdatePushNotification
    private var dispatchView: TeamDispatchView?

    @CadServiceInject
    private var cadService: CadService

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    init(occurrenceId: UUID, data: OccurrenceUpdatePushNotification) {
        self.occurrenceId = occurrenceId
        self.occurrenceUpdate = data
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom

        transitionDelegate = DefaultModalPresentationManager()
        transitioningDelegate = transitionDelegate

        if let dispatch = cadService.getDispatches().first {
            dispatchView = TeamDispatchView(dispatch: dispatch)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground

        view.addSubview(titleLabel)
        view.addSubview(updatesContainerView)
        updatesContainerView.addSubview(updatesView)
        view.addSubview(detailsBtn)
        if let dispatchView = dispatchView {
            view.addSubview(dispatchView)
        }
        view.addSubview(closeBtn)

        _ = dispatchView?.configure()

        let itemsViews = occurrenceUpdate.array.map { item in
            OccurrenceUpdatesView(item: item)
        }
        updatesView.addArrangedSubviewList(views: itemsViews)

        setupLayout()
    }

    @objc private func didTapInDetailsBtn() {
        detailsBtn.startLoad()
        self.occurrenceService.getOccurrenceById(self.occurrenceId) { result in
            garanteeMainThread {
                self.dismiss(animated: true, completion: {
                    garanteeMainThread {
                        switch result {
                        case .success(let details):
                            self.delegate?.goToDetails(occurrence: details)
                        case .failure(let error as NSError):
                            let alert = UIAlertController(
                                title: "Não foi possível detalhar a ocorrêcia",
                                message: error.domain,
                                preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                            self.present(alert, animated: true)
                        }
                    }
                })
            }
        }
    }

    @objc private func didTapInCloseBtn() {
        dismiss(animated: true)
    }

    private func setupLayout() {
        let padding: CGFloat = 20
        let safeArea = view.safeAreaLayoutGuide
        detailsBtn.width(view.widthAnchor, multiplier: 0.65).height(40)
        closeBtn.width(25).height(25)
        dispatchView?.height(110)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: closeBtn.leadingAnchor, constant: -padding),

            closeBtn.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
            closeBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),

            updatesContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            updatesContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            updatesContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),

            updatesView.topAnchor.constraint(equalTo: updatesContainerView.topAnchor),
            updatesView.leadingAnchor.constraint(equalTo: updatesContainerView.leadingAnchor),
            updatesView.trailingAnchor.constraint(equalTo: updatesContainerView.trailingAnchor),
            updatesView.bottomAnchor.constraint(equalTo: updatesContainerView.bottomAnchor),

            detailsBtn.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            detailsBtn.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -padding)
        ])

        if let dispatchView = dispatchView {
            NSLayoutConstraint.activate([
                updatesContainerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -210),

                dispatchView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
                dispatchView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),
                dispatchView.bottomAnchor.constraint(equalTo: detailsBtn.topAnchor, constant: -padding)
            ])
        }
    }
}
