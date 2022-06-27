//
//  Card.swift
//  CAD
//
//  Created by Ramires Moreira on 07/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
import HGRippleRadarView

protocol CardViewDelegate: class {
    func didSelectAMember(_ member: TeamPerson)
    func didSelectAEquipmentGroup(_ group: EquipmentGroup)
    func didStartService(_ button: UIButton)
}

class TeamCardView: UIView {
    weak var delegate: CardViewDelegate?

    private let viewModel: CadResourceViewModel
    private let groupSpacing: CGFloat = 14
    private let groupMemberHeight: CGFloat = 70
    private let groupEquipmentHeight: CGFloat = 70
    private let witdhMutiplier: CGFloat = 0.98
    private let buttonHeight: CGFloat = 30
    private let canEdite: Bool
    private let type: CadViewType

    @CadServiceInject
    private var cadService: CadService

//    var onEdite: (UIButton) -> Void = {_ in }
//    var onFavorite: (UIButton) -> Void = {_ in }
    var onDelete: (UIButton) -> Void = {_ in }
    var onActivate: (UIButton) -> Void = {_ in }
    var onFinish: (UIButton) -> Void = {_ in }
    var onSchedule: (UIButton) -> Void = {_ in }

//    private lazy var editButton: UIButton = {
//        let image = UIImage(named: "pencil")?
//            .withTintColor(.appLightGray, renderingMode: .alwaysOriginal)
//        let button = CardView.buttonBuilder(image: image, title: nil)
//        button.enableAutoLayout().height(buttonHeight).width(30)
//        button.addAction { [weak self] in
//            self?.onEdite(button)
//        }
//        return button
//    }()
//
//    private lazy var favoritButton: UIButton = {
//        let image = UIImage(systemName: "star.fill")?
//            .withTintColor(.appLightGray, renderingMode: .alwaysOriginal)
//        let button = CardView.buttonBuilder(image: image, title: nil)
//        button.enableAutoLayout().height(buttonHeight).width(35)
//        button.addAction { [weak self] in
//            self?.onFavorite(button)
//        }
//        return button
//    }()

    private lazy var deleteButton: UIButton = {
        let image = UIImage(systemName: "trash")?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        let button = TeamCardView.buttonBuilder(image: image, title: nil)
        button.enableAutoLayout().height(buttonHeight).width(35)
        button.addAction { [weak self] in
            self?.onDelete(button)
        }
        return button
    }()

    var rippleView: RippleView = {
        let radar = RippleView(frame: .init(x: 0, y: 0, width: 30, height: 30))
        radar.diskColor = .systemGreen
        radar.diskRadius = 5
        radar.numberOfCircles = 3
        radar.animationDuration = 1
        radar.circleOnColor = UIColor.systemGreen.withAlphaComponent(0.8)
        radar.circleOffColor = .clear
        radar.paddingBetweenCircles = 3
        return radar
    }()

    private lazy var finishButton: UIButton = {
        let image = UIImage(systemName: "bolt.slash.fill")?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        let button = TeamCardView.buttonBuilder(image: image, title: "Encerrar")
        button.enableAutoLayout().width(100).height(buttonHeight)
        button.backgroundColor = .appBackground
        button.setTitleColor(.systemRed, for: .normal)
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 12)
        button.addAction { [weak self] in
            self?.onFinish(button)
        }
        return button
    }()

    @objc func didStartService(_ sender: UIButton) {
        self.delegate?.didStartService(sender)
    }

    private lazy var activeButton: UIButton = {
        let image = UIImage(systemName: "bolt.fill")?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        let button = TeamCardView.buttonBuilder(image: image, title: "Ativar")
        button.enableAutoLayout().width(100).height(buttonHeight)
        button.backgroundColor = .appBackground
        button.setTitleColor(.systemGreen, for: .normal)
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 12)
        button.addAction { [weak self] in
            self?.onActivate(button)
        }
        return button
    }()

    lazy var startServiceButton: UIButton = {
        let image = UIImage(systemName: "bolt.fill")?
            .withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let button = TeamCardView.buttonBuilder(image: image, title: "Iniciar Serviço")
        button.enableAutoLayout().width(120).height(buttonHeight)
        button.backgroundColor = .clear
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.appTitle.cgColor
        button.setTitleColor(.appTitle, for: .normal)
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 12)
        button.addTarget(self, action: #selector(didStartService(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var calendarButton: UIButton = {
        let image = UIImage(systemName: "calendar")?
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        let button = TeamCardView.buttonBuilder(image: image, title: "Agendar")
        button.enableAutoLayout().width(100).height(buttonHeight)
        button.backgroundColor = .appBackground
        button.setTitleColor(.systemBlue, for: .normal)
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 12)
        button.addAction { [weak self] in
            self?.onSchedule(button)
        }
        return button
    }()

    private let scrollContainer = UIScrollView(frame: .zero).enableAutoLayout()
    private let builder = GenericDetailBuilder()

    init(model: CadResourceViewModel, type: CadViewType, canEdite: Bool = false) {
        self.canEdite = canEdite
        self.viewModel = model
        self.type = type
        super.init(frame: .zero)
        backgroundColor = .appBackgroundCell
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }

    private func setupSubviews() {
        let content = builder.verticalStack(spacing: 12, alignment: .fill, distribution: .fill).enableAutoLayout()
        builder.configurations.numberOfLinesRegular = 0

        addSubview(scrollContainer)
        scrollContainer.addSubview(content)

        addTeamName(content, builder)
        addTimesAndPhone(builder, content)
        addRegions(content, builder)
        addMembers(content, builder)
        addEquipment(content, builder)
        addDispatches(content, builder)
        addActionButtons(content, builder)

        content.fillSuperView()
        NSLayoutConstraint.activate([
            scrollContainer.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            scrollContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            scrollContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            scrollContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            content.topAnchor.constraint(equalTo: scrollContainer.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor),

            bottomAnchor.constraint(equalToSystemSpacingBelow: scrollContainer.bottomAnchor, multiplier: 1)
        ])
    }

    private static func buttonBuilder(image: UIImage?, title: String?) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.setTitleColor(.appCellLabel, for: .normal)
        button.titleLabel?.font = UIFont.robotoRegular.withSize(12)
        button.setTitleColor(UIColor.appCellLabel.withAlphaComponent(0.5), for: .highlighted)
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        return button
    }

    private func addActionButtons(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        let separator = UIView().enableAutoLayout().height(1)
        separator.backgroundColor = .memberBackGroundCell
        content.addArrangedSubview(separator)
        switch type {
        case .active:
            addActivateButtons(content, builder)
        case .template:
            addTemplateButtons(content, builder)
        case .schedule:
            addScheduledButtons(content, builder)
        default:
            return
        }
    }

    private func addActivateButtons(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        let leftView = cadService.hasStartedService() ? UIView() : startServiceButton
        let buttonContainer = builder.line(
            views: leftView, .spacer(), finishButton,
            distribuition: .fill,
            spacing: 8,
            alignment: .fill
        )
        content.addArrangedSubview(buttonContainer)
    }

    private func addTemplateButtons(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        let buttonContainer = builder.line(
            views: .spacer(), calendarButton,
            distribuition: .fill,
            spacing: 8,
            alignment: .fill
        )
        content.addArrangedSubview(buttonContainer)
    }

    private func addScheduledButtons(_ content: UIStackView, _ builder: GenericDetailBuilder) {
//        let image = favoritButton.image(for: .normal)?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
//        favoritButton.setImage(image, for: .normal)
        let buttonContainer = builder.line(
            views: .spacer(), activeButton,
            distribuition: .fill,
            spacing: 8,
            alignment: .fill
        )
        content.addArrangedSubview(buttonContainer)
    }

    private func addTeamName(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        let container = UIView().enableAutoLayout()
        let teamName = viewModel.teamName.enableAutoLayout()
        container.addSubview(teamName)
        NSLayoutConstraint.activate([
            teamName.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            teamName.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        content.addArrangedSubview(container)
        container.left(content, mutiplier: 0).width(content).height(40)
        if type == .active {
            container.addSubview(rippleView.enableAutoLayout())
            rippleView.width(40)
            NSLayoutConstraint.activate([
                teamName.trailingAnchor.constraint(equalTo: rippleView.leadingAnchor, constant: -10),
                rippleView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
                rippleView.centerYAnchor.constraint(equalTo: teamName.centerYAnchor)
            ])
        }
        content.setCustomSpacing(groupSpacing, after: teamName)
    }

    private func addTimesAndPhone(_ builder: GenericDetailBuilder, _ content: UIStackView) {
        guard let dates = viewModel.dates else { return }
        let timerViews = builder.line(views: viewModel.hours, viewModel.duration, spacing: 16)
        let phoneView = viewModel.phone
        content.addArrangedSubviewList( views: dates, timerViews, phoneView )
        content.setCustomSpacing(groupSpacing, after: timerViews)
    }

    private func addRegions(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        let regionsView = viewModel.region()?.enableAutoLayout().height(40)
        regionsView?.showsHorizontalScrollIndicator = false
        if let regions = regionsView {
            content.addArrangedSubview( builder.labelRegular(with: "Regiões de atuação:") )
            content.addArrangedSubview( regions )
        }
    }

    private func addDispatches(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        let dispatchesView = viewModel.currentDispatch()?.height(110)
        if let dispatches = dispatchesView {
            content.addArrangedSubview( builder.labelRegular(with: "Empenho atual:") )
            content.addArrangedSubview( dispatches )
        }
    }

    private func addEquipment(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        if viewModel.totalEquipament > 0 {
            let title = "Equipamentos (\(viewModel.totalEquipament)):"
            content.addArrangedSubview(builder.labelRegular(with: title))
            let equipmentCollection = EquipmentGroupCollectionView(equipments: viewModel.equipments).height(groupEquipmentHeight)
            equipmentCollection.equipmentsDelegate = self
            equipmentCollection.showsHorizontalScrollIndicator = false
            content.addArrangedSubview(equipmentCollection)
            content.setCustomSpacing(15, after: equipmentCollection)
        }
    }

    private func addMembers(_ content: UIStackView, _ builder: GenericDetailBuilder) {
        content.addArrangedSubview(builder.labelRegular(with: "Equipe:"))
        let memberCollection = MemberGroupCollectionView(people: viewModel.teamPeople).height(groupMemberHeight)
        memberCollection.membersDelegate = self
        memberCollection.showsHorizontalScrollIndicator = false
        content.addArrangedSubview(memberCollection)
    }

    override var intrinsicContentSize: CGSize {
        return .init(width: 100, height: 100)
    }

}

extension TeamCardView: MemberGroupDelegate, EquipmentGroupDelegate {
    func didSelectAMember(_ member: TeamPerson) {
        delegate?.didSelectAMember(member)
    }

    func didSelectAEquipmentGroup(_ group: EquipmentGroup) {
        delegate?.didSelectAEquipmentGroup(group)
    }
}

/// Os tipos de cards suportados
enum CadViewType {

    /// Monta o card com botões de ação  para equipes ativas
    case active

    /// Monta o card com botões de ação  para equipes agendadas
    case schedule

    /// Monta o card com botões de ação para equipes modelos
    case template

    /// Monta o card sem botões de ação
    case none
}
