//
//  TeamModalViewController.swift
//  CAD
//
//  Created by Samir Chaves on 16/04/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class TeamModalViewController: UIViewController {

    private static var cachedTeams = [UUID: NonCriticalTeam]()

    @CadServiceInject
    private var cadService: CadService

    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var teamId: UUID
    private var teamDetails: NonCriticalTeam?
    private var listBuilder: ListBasedDetailBuilder?
    private static let memberImageSize: CGFloat = 110
    private let nameLabel = UILabel.build(withSize: 19, weight: .bold, color: .appTitle, alignment: .center)
    private var viewModel: NonCriticalCadResourceViewModel?
    private let groupSpacing: CGFloat = 14
    private let groupMemberHeight: CGFloat = 75
    private let groupEquipmentHeight: CGFloat = 70
    private let witdhMutiplier: CGFloat = 0.98
    private let buttonHeight: CGFloat = 30

    lazy var scrollContainer: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.enableAutoLayout()
        return scroll
    }()

    init(teamId: UUID) {
        self.teamId = teamId
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .appBackground
        modalPresentationStyle = .custom
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func renderDetails() {
        if let teamDetails = self.teamDetails {
            view.addSubview(nameLabel)
            nameLabel.text = teamDetails.name

            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
            ])

            let builder = GenericDetailBuilder()
            builder.configurations.numberOfLinesRegular = 0
            let content = builder.verticalStack(spacing: 12, alignment: .fill, distribution: .fillProportionally)
                    .enableAutoLayout()
            view.addSubview(content)
            let space: CGFloat = 2
            content.top(to: nameLabel.bottomAnchor, mutiplier: 2).left(mutiplier: space)
            view.right(to: content.trailingAnchor, space)
            addTimes(builder, content)
            addRegionsAndAgencies(content, builder)
            addEquipment(content, builder)
            addMembers(content, builder)
        }
    }

    private func startLoading() {
        garanteeMainThread {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }

    private func stopLoading() {
        garanteeMainThread {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    private func getTeamsDetails() {
        if TeamModalViewController.cachedTeams.keys.contains(teamId),
           let team = TeamModalViewController.cachedTeams[teamId] {
            self.teamDetails = team
            self.viewModel = .init(team: team)
            self.renderDetails()
        } else {
            startLoading()
            cadService.getTeamById(teamId: teamId) { result in
                self.stopLoading()
                garanteeMainThread {
                    switch result {
                    case .success(let team):
                        self.teamDetails = team
                        self.viewModel = .init(team: team)
                        TeamModalViewController.cachedTeams[team.id] = team
                        self.renderDetails()
                    case .failure(let error as NSError):
                        if self.isUnauthorized(error) {
                            self.gotoLogin(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        getTeamsDetails()
        transitionDelegate = PresentationManager()
        transitioningDelegate = transitionDelegate
        addSubviews()
        setupLayout()
    }

    private func setupLayout() {
        activityIndicator.enableAutoLayout()
        activityIndicator.height(100).width(100)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }

    private func addSubviews() {
        view.addSubview(activityIndicator)
    }

    private static func buttonBuilder(image: UIImage?, title: String? ) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.setTitleColor(.appCellLabel, for: .normal)
        button.titleLabel?.font = UIFont.robotoRegular.withSize(12)
        button.setTitleColor(UIColor.appCellLabel.withAlphaComponent(0.5), for: .highlighted)
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        return button
    }

    private func addTimes(_ builder: GenericDetailBuilder, _ content: UIStackView) {
        if let dates = viewModel?.dates,
           let hours = viewModel?.hours,
           let duration = viewModel?.duration {
            let timerViews = builder.line(views: hours, duration, spacing: 16)
            content.addArrangedSubviewList(views: dates, timerViews)
            content.setCustomSpacing(groupSpacing, after: timerViews)
        }
    }

    private func addRegionsAndAgencies(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        if let regionsView = viewModel?.regionAndAgencies()?.enableAutoLayout().height(40) {
            regionsView.showsHorizontalScrollIndicator = false
            content.addArrangedSubview(regionsView)
        }
    }

    private func addEquipment(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        if let equipments = viewModel?.equipments, equipments.count > 0 {
            let title = "Equipamentos (\(equipments.count)):"
            content.addArrangedSubview(builder.labelRegular(with: title))
            let equipmentCollection = EquipmentGroupCollectionView(equipments: equipments, isInteractable: false).height(groupEquipmentHeight)
            equipmentCollection.showsHorizontalScrollIndicator = false
            content.addArrangedSubview(equipmentCollection)
            content.setCustomSpacing(15, after: equipmentCollection)
        }
    }

    private func addMembers(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        if let teamPeople = viewModel?.teamPeople {
            content.addArrangedSubview(builder.labelRegular(with: "Equipe:"))
            let memberCollection = MemberGroupCollectionView(people: teamPeople).height(groupMemberHeight)
            memberCollection.showsHorizontalScrollIndicator = false
            content.addArrangedSubview(memberCollection)
        }
    }
}
