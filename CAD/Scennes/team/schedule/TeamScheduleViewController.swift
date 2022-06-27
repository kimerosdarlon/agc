//
//  TeamScheduleViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 10/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

public class TeamScheduleViewController: UIViewController {

    private let addButton = FloatButton()
    private var scheduledTeams: [Team] = []

    @CadServiceInject
    private var service: CadService

    private let teamTable: UITableView = {
        let table = UITableView().enableAutoLayout()
        table.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        table.backgroundColor = .appBackground
        table.separatorStyle = .none
        return table
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "Equipes"
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.scheduledTeams = service.getScheduledTeams()
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        view.addSubview(teamTable)
        teamTable.fillSuperView(regardSafeArea: true)

//        view.addSubview(addButton)
//        let safeArea = view.safeAreaLayoutGuide
//        NSLayoutConstraint.activate([
//            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: addButton.trailingAnchor, multiplier: 3),
//            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: addButton.bottomAnchor, multiplier: 3)
//        ])
//        addButton.addTarget(self, action: #selector(addButtonDidClicked), for: .touchUpInside)
        setupEmtpyStateIfNeeded()
        teamTable.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupEmtpyStateIfNeeded() {
        if !scheduledTeams.isEmpty { return }
        self.teamTable.isHidden = true
        let subtitle = "Toque no botão de recarregar no canto superior direito para procurar novas alocações."
        let emptyView = EmptyStateView(title: "Nenhuma equipe para ativar",
                                       subTitle: subtitle,
                                       image: UIImage(named: "equipe")! )
        view.addSubview(emptyView)
        emptyView.enableAutoLayout().fillSuperView()
        emptyView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        view.insertSubview(addButton, aboveSubview: emptyView)
    }

    @objc
    private func addButtonDidClicked() {
        let formController = NewScheduleTeamViewController()
        let navigation = UINavigationController(rootViewController: formController)
        self.present(navigation, animated: true, completion: nil)
    }
}

extension TeamScheduleViewController: UITableViewDataSource, TeamTableViewCellDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduledTeams.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
        cell.configure(with: self.scheduledTeams[indexPath.item], andDelegate: self)
        cell.delegate = self
        return cell
    }

    func didClickOnEditeButton(_ team: Team) {
        print("editar uma equipe agendade")
    }

    func didClickOnFavoriteButton(_ team: Team) {
        print("favoritar uma equipe agendade")
    }

    func didClickOnActivateButton(_ team: Team) {
        let alertController = UIAlertController(
            title: "Ativação \(team.name)",
            message: "Olá, \(Date().toGreet()), vamos para as revisões mínimas para assumir o serviço?",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .destructive))
        alertController.addAction(UIAlertAction(title: "Prosseguir", style: .default, handler: { _ in
            self.navigationController?.pushViewController(QuestionsViewController(withTeam: team), animated: true)
        }))

        self.present(alertController, animated: true, completion: nil)
    }
}

extension TeamScheduleViewController: CardViewDelegate {
    func didSelectAMember(_ member: TeamPerson) {
        self.present(MemberModalViewController(person: member), animated: true)
    }

    func didSelectAEquipmentGroup(_ group: EquipmentGroup) {
        self.present(EquipmentModalViewController(group: group), animated: true)
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
                if let alertController = alertController {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

protocol TeamTableViewCellDelegate: class {
    func didClickOnEditeButton(_ team: Team)
    func didClickOnFavoriteButton(_ team: Team)
    func didClickOnActivateButton(_ team: Team)
}

class TeamTableViewCell: UITableViewCell {

    weak var delegate: TeamTableViewCellDelegate?
    @CadServiceInject
    private var service: CadService

    static let identifier = String(describing: TeamTableViewCell.self)

    func configure(with team: Team, andDelegate cardDelegate: CardViewDelegate) {
        let card = TeamCardView(model: .init(team: team), type: .schedule)
        card.delegate = cardDelegate
//        card.onEdite = { _ in
//            self.delegate?.didClickOnEditeButton(team)
//        }
        card.onActivate = { _ in
            self.delegate?.didClickOnActivateButton(team)
        }
//        card.onFavorite = { _ in
//            self.delegate?.didClickOnFavoriteButton(team)
//        }
        selectionStyle = .none
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        contentView.addSubview(card)
        card.enableAutoLayout().fillSuperView(regardSafeArea: true)
        contentView.backgroundColor = .appBackground
    }
}
