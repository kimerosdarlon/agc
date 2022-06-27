//
//  ModalTeamViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 05/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
import Location

public class ModalTeamViewController: UIViewController {
    public weak var presenter: ModalTeamPresenter?

    private var nextButton = AGCRoundedButton(text: "Iniciar serviço")
    private var skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Pular", for: .normal)
        btn.setTitleColor(.appTitle, for: .normal)
        btn.backgroundColor = .clear
        btn.isHidden = true
        return btn.enableAutoLayout()
    }()

    private var contentView: UIStackView = {
        let content = UIStackView()
        content.enableAutoLayout()
        content.axis = .vertical
        content.alignment = .center
        return content
    }()
    var card: TeamCardView!

    var viewModel: CadResourceViewModel
    let header = HeaderModalTeamView()
    private let startServiceError = ErrorView()

    @CadServiceInject
    private var service: CadService

    private var trackingService = RTTrackingService.shared

    private let locationService = LocationService.shared

    private var errorViewHeightConstraint: NSLayoutConstraint?

    public init(withResource model: CadResourceViewModel) {
        self.viewModel = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        view.backgroundColor = .appBackground
        card = TeamCardView(model: viewModel, type: .none)
        card.delegate = self
        addSubviews()
        nextButton.addTarget(self, action: #selector(nextButtonDidClick), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonDidClick), for: .touchUpInside)
    }

    private func addSubviews() {
        view.addSubview(startServiceError)
        view.addSubview(contentView)
        let width = view.frame.width
        let safeArea = view.safeAreaLayoutGuide

        errorViewHeightConstraint = startServiceError.heightAnchor.constraint(equalToConstant: 0)
        errorViewHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1),
            contentView.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 1),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: contentView.trailingAnchor, multiplier: 1),
            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: contentView.bottomAnchor, multiplier: 3)
        ])
        contentView.addArrangedSubview(header.width(width * 0.95))
        contentView.setCustomSpacing(20, after: header)
        contentView.addArrangedSubview(startServiceError)
        contentView.setCustomSpacing(20, after: startServiceError)
        contentView.addArrangedSubview(card.width(width * 0.95))
        contentView.addArrangedSubview(.spacer())
        contentView.addArrangedSubview(nextButton.width(width/2).height(45))
        contentView.addArrangedSubview(skipButton.width(width/2).height(45))
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.modalTeamDidDismiss()
    }

    @objc
    func nextButtonDidClick() {
        guard let activeTeam = service.getActiveTeam() else { return }
        if activeTeam.equipments.isEmpty {
            startService()
        } else {
            let equipmentPicker = EquipmentPickerViewController()
            equipmentPicker.delegate = self
            present(equipmentPicker, animated: true)
        }
    }

    @objc func skipButtonDidClick() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ModalTeamViewController: CardViewDelegate, EquipmentPickerDelegate {
    func didSelectAMember(_ member: TeamPerson) {
        self.present(MemberModalViewController(person: member), animated: true)
    }

    func didSelectAEquipmentGroup(_ group: EquipmentGroup) {
        self.present(EquipmentModalViewController(group: group), animated: true)
    }

    func startService() {
        nextButton.startLoad()
        service.startService { [weak self] response in
            garanteeMainThread {
                self?.nextButton.stopLoad()
                switch response {
                case .success:
                    let alert = UIAlertController(title: "Serviço iniciado com sucesso", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        self?.dismiss(animated: true, completion: nil)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    self?.errorViewHeightConstraint?.isActive = true
                    self?.locationService.startUpdatingLocation()
                    self?.trackingService.scheduleSendingUserLocation()
                case .failure(let error as NSError):
                    self?.startServiceError.setText(error.domain)
                    self?.nextButton.setTitle("Tentar novamente", for: .normal)
                    self?.skipButton.isHidden = false
                    self?.errorViewHeightConstraint?.isActive = false
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
        self.service.startService { result in
            garanteeMainThread {
                button.alpha = 1
                var alertController: UIAlertController?
                switch result {
                case .success:
                    button.isHidden = true
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
                        alertController!.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { _ in
                            alertController!.dismiss(animated: true)
                        }))
                        alertController!.addAction(UIAlertAction(title: "Tentar novamente", style: .default, handler: { _ in
                            self.didStartService(button)
                        }))
                    }
                }
                if let alertController = alertController {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
