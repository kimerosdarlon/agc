//
//  NearTeamDetailView.swift
//  CAD
//
//  Created by Samir Chaves on 28/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

protocol NearTeamDetailDelegate: class {
    func didSelectOnlineMember(_ member: SimpleTeamPerson)
    func didCloseDetails()
    func didRouteToMember(_ member: SimpleTeamPerson)
}

extension NearTeamDetailDelegate {
    func didCloseDetails() { }
    func didRouteToMember(_ member: SimpleTeamPerson) {}
}

class NearTeamDetailView: UIView {
    weak var teamDelegate: NearTeamDetailDelegate?

    private let teamDetails: NonCriticalTeam
    private var onlineMembersCpfs: [String]
    private var viewModel: NonCriticalCadResourceViewModel?
    private let nameLabel = UILabel.build(withSize: 19, weight: .bold, color: .appTitle)
    private static let memberImageSize: CGFloat = 110
    private let groupSpacing: CGFloat = 14
    private let groupMemberHeight: CGFloat = 70
    private let groupEquipmentHeight: CGFloat = 70
    private let witdhMutiplier: CGFloat = 0.98
    private let buttonHeight: CGFloat = 30
    private var selectedMember: SimpleTeamPerson?
    private var contentBottomConstraint: NSLayoutConstraint?
    private var onlineMembersCollectionView: MemberGroupCollectionView?

    @CadServiceInject
    private var cadService: CadService

    private let routeButton: UIButton = {
        let image = UIImage(named: "routing")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Rota", for: .normal)
        btn.setImage(image, for: .normal)
        if let imageView = btn.imageView,
           let titleLabel = btn.titleLabel {
            imageView.enableAutoLayout().width(25).height(25)
            titleLabel.enableAutoLayout().centerY(view: btn)
            imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -10).isActive = true
            titleLabel.centerXAnchor.constraint(equalTo: btn.centerXAnchor, constant: 10).isActive = true
        }
        btn.setTitleColor(.appCellLabel, for: .normal)
        btn.backgroundColor = .appBackgroundCell
        btn.addTarget(self, action: #selector(didTapOnRouteBtn), for: .touchUpInside)
        return btn
    }()

    @objc private func didTapOnRouteBtn() {
        if let selectedMember = self.selectedMember {
            teamDelegate?.didRouteToMember(selectedMember)
        }
    }

    lazy var scrollContainer = UIScrollView(frame: .zero).enableAutoLayout()

    init(team: NonCriticalTeam, onlineMembersCpfs: [String]) {
        self.teamDetails = team
        self.onlineMembersCpfs = onlineMembersCpfs
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        self.viewModel = .init(team: teamDetails)
        addSubview(nameLabel)
        nameLabel.text = teamDetails.name

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15)
        ])

        let builder = GenericDetailBuilder()
        builder.configurations.numberOfLinesRegular = 0
        let content = builder.verticalStack(spacing: 12, alignment: .fill, distribution: .fillProportionally)
                .enableAutoLayout()
        addSubview(scrollContainer)
        addSubview(routeButton)
        routeButton.height(30).width(scrollContainer)
        scrollContainer.addSubview(content)
        let space: CGFloat = 2
        content.top(to: nameLabel.bottomAnchor, mutiplier: 2).left(mutiplier: space)
        right(to: content.trailingAnchor, space)
        addTimes(builder, content)
        addRegionsAndAgencies(content, builder)
        addEquipment(content, builder)
        onlineMembersCollectionView = addMembers(content, builder)

        NSLayoutConstraint.activate([
            scrollContainer.topAnchor.constraint(equalTo: topAnchor),
            scrollContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollContainer.bottomAnchor.constraint(equalTo: routeButton.topAnchor),

            routeButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        routeButton.isHidden = true
        contentBottomConstraint = scrollContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        contentBottomConstraint?.isActive = true
    }

    private func buttonBuilder(image: UIImage?, title: String? ) -> UIButton {
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

    private func sortOnline(members: [SimpleTeamPerson]) -> [SimpleTeamPerson] {
        return members.sorted { (person1: SimpleTeamPerson, person2: SimpleTeamPerson) -> Bool in
            guard let person1Cpf = person1.person.cpf else { return false }
            guard let person2Cpf = person2.person.cpf else { return false }
            let person1IsOnline = self.onlineMembersCpfs.contains(person1Cpf)
            let person2IsOnline = self.onlineMembersCpfs.contains(person2Cpf)
            return (person1IsOnline == person2IsOnline) ? true : (person1IsOnline ? true : false)
        }
    }

    private func addMembers(_ content: UIStackView, _ builder: GenericDetailBuilder) -> MemberGroupCollectionView? {
        if let teamPeople = viewModel?.teamPeople {
            content.addArrangedSubview(builder.labelRegular(with: "Equipe:"))
            let memberCollection = MemberGroupCollectionView(
                people: sortOnline(members: teamPeople),
                onlinePeopleCpfs: onlineMembersCpfs
            ).height(groupMemberHeight)
            memberCollection.membersDelegate = self
            memberCollection.showsHorizontalScrollIndicator = false
            content.addArrangedSubview(memberCollection)
            return memberCollection
        }
        return nil
    }

    func updateOnlineMembers(cpfs: [String]) {
        if let teamPeople = viewModel?.teamPeople {
            self.onlineMembersCpfs = cpfs
            onlineMembersCollectionView?.configure(withPeople: sortOnline(members: teamPeople),
                                                   onlinePeopleCpfs: cpfs)
        }
    }
}

extension NearTeamDetailView: MemberGroupDelegate {
    func didSelectAMember(_ member: SimpleTeamPerson) {
        if let memberCpf = member.person.cpf,
           let currentUserCpf = cadService.getProfile()?.person.cpf,
           onlineMembersCpfs.contains(memberCpf) {
            if currentUserCpf != memberCpf {
                selectedMember = member

                routeButton.setTitle("Rota até \(member.person.functionalName)", for: .normal)
                routeButton.fadeIn()
                contentBottomConstraint?.constant = -55
            } else {
                routeButton.fadeOut()
                contentBottomConstraint?.constant = 0
            }
            teamDelegate?.didSelectOnlineMember(member)
        }
    }
}
