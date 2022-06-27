//
//  ActiveTeamViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 10/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

public class ActiveTeamViewController: UIViewController {

    @CadServiceInject
    private var cadService: CadService

    private let teamView: TeamCardView
    private let team: CadResourceViewModel

    public init(team: CadResourceViewModel) {
        self.teamView = TeamCardView(model: team, type: .active, canEdite: true)
        self.team = team
        super.init(nibName: nil, bundle: nil)
        self.teamView.delegate = self
        self.bindEvents()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Equipes"
        view.addSubview(teamView)
        teamView.enableAutoLayout()
        teamView.top(mutiplier: 2).left(mutiplier: 2)
        view.right(to: teamView.trailingAnchor, 2)
    }

    private func bindEvents() {
//        teamView.onFavorite = { [weak self] _ in
//            guard let team = self?.team else { return }
//            self?.didClickFavorite(team: team)
//        }
//
//        teamView.onEdite = { [weak self] _ in
//            guard let team = self?.team else { return }
//            self?.didClickEdite(team: team)
//        }

        teamView.onFinish = { [weak self] _ in
            guard let team = self?.team else { return }
            self?.didClickFinish(team: team)
        }
    }

    private func didClickFavorite(team: CadResourceViewModel) {
        print("favoritar o time")
    }

    private func didClickFinish(team: CadResourceViewModel) {
        let justificativeViewController = JustificativeViewController(forTeam: team.getTeam())
        self.navigationController?.pushViewController(justificativeViewController, animated: true)
    }

    private func didClickEdite(team: CadResourceViewModel) {
        print("editar o time")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension ActiveTeamViewController: CardViewDelegate, EquipmentPickerDelegate {
    func didSelectAMember(_ member: TeamPerson) {
        self.present(MemberModalViewController(person: member), animated: true)
    }

    func didSelectAEquipmentGroup(_ group: EquipmentGroup) {
        self.present(EquipmentModalViewController(group: group), animated: true)
    }

    func startService() {
        self.cadService.startService { result in
            garanteeMainThread {
                self.teamView.startServiceButton.alpha = 1
                var alertController: UIAlertController?
                switch result {
                case .success:
                    self.teamView.startServiceButton.isHidden = true
                    alertController = UIAlertController(
                        title: "Serviço iniciado com sucesso",
                        message: nil,
                        preferredStyle: .alert
                    )
                    alertController!.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                case .failure(let error as NSError):
                    if self.isUnauthorized(error) {
                        self.gotoLogin(error.domain)
                    } else {
                        alertController = UIAlertController(
                            title: "Não foi possível iniciar o serviço",
                            message: error.domain,
                            preferredStyle: .alert
                        )
                        let actions = [
                            UIAlertAction(title: "Cancelar", style: .destructive, handler: { _ in
                                alertController!.dismiss(animated: true)
                            }),
                            UIAlertAction(title: "Tentar novamente", style: .default, handler: { _ in
                                self.didStartService(self.teamView.startServiceButton)
                            })
                        ]
                        actions.forEach { alertController!.addAction($0) }
                    }
                }

                if let alertController = alertController {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func didSkip() {
        startService()
    }

    func didSelect(equipment: Equipment?) {
        startService()
    }

    func didStartService(_ button: UIButton) {
        button.alpha = 0.6
        guard let activeTeam = cadService.getActiveTeam() else { return }
        if activeTeam.equipments.isEmpty {
            startService()
        } else {
            let equipmentPicker = EquipmentPickerViewController()
            equipmentPicker.delegate = self
            present(equipmentPicker, animated: true)
        }
    }
}
