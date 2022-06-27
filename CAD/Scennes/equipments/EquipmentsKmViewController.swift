//
//  EquipmentsKmViewController.swift
//  CAD
//
//  Created by Samir Chaves on 25/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

enum TeamAction {
    case activate
    case finish
}

class EquipmentsKmViewController: UIViewController {

    private var equipments = [Equipment]()
    private var kmByEquipment = [UUID: String]()
    private var checklistReply: ReplyForm?
    private var finishReason: String?
    private var teamId: UUID?
    private var teamAction: TeamAction = .activate
    private var retried = false
    private var initialTeam: Team?

    @CadServiceInject
    private var cadService: CadService

    private let finishButton = AGCRoundedButton(text: "Finalizar")
        .setRightIcon(UIImage(systemName: "arrow.right")!.withTintColor(.white, renderingMode: .alwaysOriginal))
        .enableAutoLayout()
        .width(110).height(40)
    private let backButton = AGCRoundedButton(text: "Voltar").enableAutoLayout().width(100).height(40)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTitle
        label.text = "Sua equipe possui veículos cadastrados"
        label.enableAutoLayout()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.contentMode = .scaleToFill
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTitle
        label.text = "Registre a quilometragem atual de cada veículo abaixo, caso julgue necessário."
        label.enableAutoLayout()
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
        return label
    }()

    private let equipmentsListContainer: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.enableAutoLayout()
        return scrollView
    }()

    private let equipmentsListView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 2
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.axis = .vertical
        stack.enableAutoLayout()
        return stack
    }()

    init(toFinishTeam teamId: UUID, withEquipments equipments: [Equipment], andJustificative reason: String) {
        super.init(nibName: nil, bundle: nil)
        teamAction = .finish
        self.teamId = teamId
        finishReason = reason
        finishButton.backgroundColor = .appRedAlert
        finishButton.setTitle("Encerrar", for: .normal)
        self.equipments = equipments
    }

    init(toActivateTeam teamId: UUID, withEquipments equipments: [Equipment], andReply reply: ReplyForm) {
        super.init(nibName: nil, bundle: nil)
        self.checklistReply = reply
        self.teamId = teamId
        self.teamAction = .activate
        self.equipments = equipments
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(finishButton)
        view.addSubview(backButton)
        view.addSubview(equipmentsListContainer)
        equipmentsListContainer.addSubview(equipmentsListView)
        equipments.forEach { equipment in
            let equipmentView = EquipmentEditingView()
            equipmentsListView.addArrangedSubview(equipmentView)
            equipmentView.configure(withEquipment: equipment)
            equipmentView.height(70)

            if let km = equipment.km {
                self.kmByEquipment[equipment.id] = String(km)
            }
            equipmentView.onEdit = { kmValue in
                self.kmByEquipment[equipment.id] = kmValue
            }
        }
    }

    private func setupLayoutConstraints() {
        let padding: CGFloat = 2
        let safeArea = view.safeAreaLayoutGuide

        equipmentsListContainer.width(view)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            safeArea.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -15),
            safeArea.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 15),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            safeArea.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -15),
            safeArea.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 15),

            equipmentsListView.topAnchor.constraint(equalTo: equipmentsListContainer.topAnchor),
            safeArea.leadingAnchor.constraint(equalTo: equipmentsListView.leadingAnchor),
            safeArea.trailingAnchor.constraint(equalTo: equipmentsListView.trailingAnchor),

            equipmentsListContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            equipmentsListContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            equipmentsListContainer.bottomAnchor.constraint(equalTo: equipmentsListView.bottomAnchor),

            view.trailingAnchor.constraint(equalToSystemSpacingAfter: finishButton.trailingAnchor, multiplier: padding),
            finishButton.topAnchor.constraint(equalToSystemSpacingBelow: equipmentsListContainer.bottomAnchor, multiplier: padding),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: finishButton.bottomAnchor, multiplier: padding),

            backButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: padding),
            backButton.centerYAnchor.constraint(equalTo: finishButton.centerYAnchor)
        ])
    }

    private func equipmentsHasChanged(current: [Equipment], new: [Equipment]) -> Bool {
        let currentIds = Set(current.map { $0.id })
        let newIds = Set(new.map { $0.id })
        return currentIds != newIds
    }

    private func buildRestartPage(newTeam: Team) -> UIViewController {
        let serverError = EmptyStateView(
            title: "Não foi possível ativar a equipe",
            subTitle: "Foi verificado que sua equipe recebeu uma atualização nos equipamentos. Será preciso realizar o preenchimento do formulário de ativação (checklist) de equipe novamente.",
            image: UIImage(named: "service")!
        ).enableAutoLayout()

        let errorPage = UIViewController()
        errorPage.view.backgroundColor = .appBackground
        errorPage.view.addSubview(serverError)
        let safeArea = errorPage.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            serverError.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            serverError.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            serverError.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
        serverError.actionButton.setTitle("Preencher novamente", for: .normal)
        serverError.onAction = {
            self.navigationController?.setViewControllers([TeamViewController(), QuestionsViewController(withTeam: newTeam)], animated: true)
        }
        return errorPage
    }

    private func handleServiceStarted() {
        self.cadService.refreshResource { error in
            garanteeMainThread {
                if let error = error as NSError?, self.isUnauthorized(error) {
                    self.gotoLogin(error.domain)
                } else {
                    self.finishButton.stopLoad()
                    self.navigationController?.setViewControllers([TeamViewController()], animated: true)
                }
            }
        }
    }

    private func handleServiceDidNotStart(error: NSError) {
        let previousTeam = self.cadService.getScheduledTeams().first(where: { $0.id == self.teamId })
        if !retried {
            initialTeam = previousTeam
        }

        retried = true

        self.cadService.refreshResource { _ in
            garanteeMainThread {
                self.finishButton.stopLoad()

                let currentTeam = self.cadService.getScheduledTeams().first(where: { $0.id == self.teamId })
                let activeTeam = self.cadService.getActiveTeam()

                if let activeTeam = activeTeam,
                   let previousTeam = previousTeam,
                   activeTeam.name == previousTeam.name {
                    self.navigationController?.setViewControllers([TeamViewController()], animated: true)
                } else if let previousTeam = self.initialTeam,
                          let currentTeam = currentTeam,
                          self.equipmentsHasChanged(current: previousTeam.equipments, new: currentTeam.equipments) {
                    // Check if any equipment has changed during the process of start service of a team.
                    // If yes, the user must answer the checklist again.
                    let restartPage = self.buildRestartPage(newTeam: currentTeam)
                    self.navigationController?.pushViewController(restartPage, animated: true)
                } else {
                    var finalError = error
                    if error.code == 400 || error.code == 422 {
                        finalError = NSError(
                            domain: "\(error.domain)\nPara mais informações, por favor, entre em contato com o despachante de sua agência.",
                            code: error.code,
                            userInfo: error.userInfo
                        )
                    }
                    self.showErrorPage(title: "Não foi possível ativar a equipe.", error: finalError, onRetry: {
                        garanteeMainThread {
                            if let activeTeamName = activeTeam?.name,
                               let currentTeam = currentTeam,
                               activeTeamName == currentTeam.name {
                                self.navigationController?.setViewControllers([TeamViewController()], animated: true)
                            } else {
                                self.startService()
                            }
                        }
                    })
                }
            }
        }
    }

    private func fetchServiceStarting() {
        let equipmentsKms = kmByEquipment.map { (id, km) in
            EquipmentKm(km: km, id: id)
        }
        if let checklistReply = checklistReply {
            finishButton.startLoad()
            self.cadService.startService(withEquipments: equipmentsKms, andChecklistReply: checklistReply) { result in
                switch result {
                case .success:
                    self.handleServiceStarted()
                case .failure(let error as NSError):
                    self.handleServiceDidNotStart(error: error)
                }
            }
        }
    }

    @objc private func startService() {
        if equipments.isEmpty {
            self.startService()
        } else {
            let equipmentPicker = EquipmentPickerViewController(equipments: equipments)
            equipmentPicker.delegate = self
            present(equipmentPicker, animated: true)
        }
    }

    @objc private func finishTeam() {
        let equipmentsKms = kmByEquipment.map { (id, km) in
            EquipmentKm(km: km, id: id)
        }
        if let teamId = teamId,
           let finishReason = finishReason {
            finishButton.startLoad()
            self.cadService.finishTeam(teamId: teamId, finishModel: FinishTeam(reason: finishReason, equipments: equipmentsKms)) { result in
                switch result {
                case .success:
                    self.cadService.refreshResource { error in
                        garanteeMainThread {
                            if let error = error as NSError?, self.isUnauthorized(error) {
                                self.gotoLogin(error.domain)
                            } else {
                                self.finishButton.stopLoad()
                                self.navigationController?.setViewControllers([TeamViewController()], animated: true)
                            }
                        }
                    }
                case .failure(let error as NSError):
                    self.finishButton.stopLoad()
                    self.showErrorPage(title: "Não foi possível encerrar a equipe.", error: error, onRetry: {
                        self.finishTeam()
                    })
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.backgroundColor = .clear

        addSubviews()
        setupLayoutConstraints()

        switch teamAction {
        case .activate:
            finishButton.addTarget(self, action: #selector(startService), for: .touchUpInside)
        case .finish:
            finishButton.addTarget(self, action: #selector(finishTeam), for: .touchUpInside)
        }

        view.backgroundColor = .appBackground
    }
}

extension EquipmentsKmViewController: EquipmentPickerDelegate {
    func didSkip() {
        fetchServiceStarting()
    }

    func didSelect(equipment: Equipment?) {
        fetchServiceStarting()
    }
}
