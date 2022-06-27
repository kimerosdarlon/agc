//
//  JustificativeViewController.swift
//  CAD
//
//  Created by Samir Chaves on 30/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class JustificativeViewController: UIViewController {

    private var teamToFinish: Team?
    private var justificative: String?

    @CadServiceInject
    private var cadService: CadService

    private let finishButton = AGCRoundedButton(text: "Continuar")
        .setRightIcon(UIImage(systemName: "arrow.right")!.withTintColor(.white, renderingMode: .alwaysOriginal))
        .enableAutoLayout()
        .width(110).height(40)
    private let backButton = AGCRoundedButton(text: "Voltar").enableAutoLayout().width(100).height(40)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTitle
        label.text = "Justifique o motivo do encerramento da equipe"
        label.enableAutoLayout()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.contentMode = .scaleToFill
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTitle
        label.text = "Para que a equipe possa ser encerrada é necessário informar a justificativa do encerramento."
        label.enableAutoLayout()
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
        return label
    }()

    private let justificativeTextField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = UIColor.textField.withAlphaComponent(0.1)
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        textField.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        textField.layer.cornerRadius = 5
        textField.enableAutoLayout()
        textField.keyboardType = .alphabet
        textField.autocorrectionType = .no
        textField.font = UIFont.systemFont(ofSize: 15)
        return textField
    }()

    init(forTeam team: Team) {
        super.init(nibName: nil, bundle: nil)
        teamToFinish = team
        titleLabel.text = "Justifique o motivo do encerramento da \(team.name)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        finishButton.isEnabled = false
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(justificativeTextField)
        view.addSubview(finishButton)
        view.addSubview(backButton)
    }

    private func setupLayoutConstraints() {
        let padding: CGFloat = 2
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            safeArea.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -15),
            safeArea.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 15),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            safeArea.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -15),
            safeArea.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 15),

            justificativeTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            justificativeTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            justificativeTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            justificativeTextField.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -20),

            view.trailingAnchor.constraint(equalToSystemSpacingAfter: finishButton.trailingAnchor, multiplier: padding),
            finishButton.bottomAnchor.constraint(equalToSystemSpacingBelow: safeArea.bottomAnchor, multiplier: padding),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: finishButton.bottomAnchor, multiplier: padding),

            backButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: padding),
            backButton.centerYAnchor.constraint(equalTo: finishButton.centerYAnchor)
        ])
    }

    private func backToTeamsScreen() {
        cadService.refreshResource { error in
            garanteeMainThread {
                if let error = error as NSError?, self.isUnauthorized(error) {
                    self.gotoLogin(error.domain)
                } else {
                    self.navigationController?.setViewControllers([TeamViewController()], animated: true)
                }
            }
        }
    }

    private func finishTeam(_ team: Team, withJustificative justificative: String) {
        finishButton.startLoad()
        self.cadService.finishTeam(teamId: team.id, finishModel: FinishTeam(reason: justificative, equipments: [])) { result in
            switch result {
            case .success:
                garanteeMainThread {
                    self.finishButton.stopLoad()
                    SuccessViewController(feedbackText: "Sua equipe foi encerrada!", backgroundColor: .appRedAlert)
                        .showModal(self, duration: 1.5) {
                            self.backToTeamsScreen()
                        }
                }
            case .failure(let error as NSError):
                if self.isUnauthorized(error) {
                    self.gotoLogin(error.domain)
                }
            }
        }
    }

    @objc private func justificate() {
        if let team = teamToFinish {
            if let justificative = justificative, !justificative.isEmpty {
                if team.hasVehicles() {
                    let equipmentsViewController = EquipmentsKmViewController(toFinishTeam: team.id, withEquipments: team.getVehicles(), andJustificative: justificative)
                    self.navigationController?.pushViewController(equipmentsViewController, animated: true)
                } else {
                    finishTeam(team, withJustificative: justificative)
                }
            } else {
                let controller = UIAlertController(title: "Informe a razão do encerramento da equipe", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                controller.addAction(ok)
                present(controller, animated: true, completion: nil)
            }
        }
    }

    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        finishButton.addTarget(self, action: #selector(justificate), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.backgroundColor = .clear
        finishButton.backgroundColor = .appRedAlert

        justificativeTextField.delegate = self

        addSubviews()
        setupLayoutConstraints()

        view.backgroundColor = .appBackground
    }
}

extension JustificativeViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        justificative = textView.text
        if justificative != nil && !justificative!.isEmpty {
            finishButton.isEnabled = true
        } else {
            finishButton.isEnabled = false
        }
    }
}
