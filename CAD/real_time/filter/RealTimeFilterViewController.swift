//
//  RealTimeFilterViewController.swift
//  CAD
//
//  Created by Samir Chaves on 17/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import ViewPager_Swift

class RealTimeFilterViewController: UIViewController {
    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    @CadServiceInject
    private var cadService: CadService

    var controllers = [UIViewController]()
    var viewPager: ViewPager!
    let occurrences: RTOccurrencesFilterViewController
    let teams: RTTeamsFilterViewController
    private let tabsContainerView = UIView(frame: .zero)
    private let headerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .appBackground
        view.enableAutoLayout()
        return view
    }()
    private let titleLabel = UILabel.build(withSize: 17, weight: .bold, color: .appTitle, text: "Filtros")
    private var initialPage = 0

    private let closeButton: UIButton = {
        let image = UIImage(systemName: "xmark")?.withTintColor(UIColor.appTitle.withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .custom)
        btn.frame = .init(x: 5, y: 5, width: 40, height: 40)
        btn.layer.cornerRadius = btn.bounds.height * 0.5
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 13)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn.enableAutoLayout().height(40).width(40)
    }()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Salvar", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .appBlue
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()

    private let cleanButton: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Limpar", for: .normal)
        btn.setTitleColor(.appCellLabel, for: .normal)
        btn.backgroundColor = .appBackgroundCell
        btn.addTarget(self, action: #selector(didClean), for: .touchUpInside)
        return btn
    }()

    private let pagerOptions: ViewPagerOptions = {
        let option = AppDefaults().pagerOptions
        option.tabViewHeight = 45
        option.distribution = .segmented
        option.tabViewPaddingLeft = 10
        option.tabViewTextFont = UIFont.systemFont(ofSize: 15.0)
        option.shadowOpacity = 0.1
        return option
    }()

    init(occurrencesDataSource: RecentOccurrencesDataSource, teamsManager: TeamMembersManager) {
        self.occurrences = RTOccurrencesFilterViewController(dataSource: occurrencesDataSource)
        self.teams = RTTeamsFilterViewController(manager: teamsManager)
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitionDelegate = DefaultModalPresentationManager()
        transitioningDelegate = transitionDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didClean() {
        self.occurrences.didClean()
        self.teams.didClean()
    }

    @objc private func handleClose() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        view.backgroundColor = .appBackground
        view.addSubview(tabsContainerView)
        view.addSubview(headerView)
        view.addSubview(cleanButton)
        view.addSubview(saveButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        headerView.height(70)
            .width(view)
            .left(view, mutiplier: 0)
            .top(view, mutiplier: 0)
        titleLabel.left(headerView, mutiplier: 2).centerY(view: headerView)
        closeButton.right(to: headerView.trailingAnchor, -25).centerY(view: headerView)

        cleanButton.height(45)
            .left(view, mutiplier: 0)
            .width(view.widthAnchor, multiplier: 0.5)
            .bottom(to: view.bottomAnchor, 0)
        saveButton.height(45)
            .left(cleanButton.trailingAnchor, mutiplier: 0)
            .width(view.widthAnchor, multiplier: 0.5)
            .bottom(to: view.bottomAnchor, 0)

        tabsContainerView
            .enableAutoLayout()
            .width(view)
            .left(view, mutiplier: 0)
            .right(to: view.leadingAnchor, 0)
            .top(to: view.topAnchor, mutiplier: 7)
            .bottom(to: cleanButton.topAnchor, 0)
        tabsContainerView.frame = view.frame.inset(by: .init(top: 70, left: 0, bottom: 0, right: 0))

        if cadService.realtimeOccurrencesAllowed() && cadService.realtimeExternalTeamsAllowed() {
            controllers.append(contentsOf: [occurrences, teams])
            viewPager = ViewPager(viewController: self, containerView: tabsContainerView)
            viewPager.setOptions(options: pagerOptions)
            viewPager.setDataSource(dataSource: self)
            viewPager.setDelegate(delegate: self)
            viewPager.build()
            view.height(1000)
        } else if cadService.realtimeExternalTeamsAllowed() {
            tabsContainerView.addSubview(teams.view)
            teams.view.enableAutoLayout()
            teams.view.width(tabsContainerView).height(tabsContainerView)
            addChild(teams)
            teams.didMove(toParent: self)
        } else if cadService.realtimeOccurrencesAllowed() {
            tabsContainerView.addSubview(occurrences.view)
            occurrences.view.enableAutoLayout()
            occurrences.view.width(tabsContainerView).height(tabsContainerView)
            addChild(occurrences)
            occurrences.didMove(toParent: self)
        }

        view.layer.masksToBounds = true
    }
}

extension RealTimeFilterViewController: ViewPagerDataSource, ViewPagerDelegate {

    func numberOfPages() -> Int { controllers.count }

    func viewControllerAtPosition(position: Int) -> UIViewController { controllers[position] }

    func tabsForPages() -> [ViewPagerTab] {
        return controllers.map({ ViewPagerTab(title: $0.title ?? "Sem título", image: nil) })
    }

    func startViewPagerAtIndex() -> Int { initialPage }

    func willMoveToControllerAtIndex(index: Int) { }

    func didMoveToControllerAtIndex(index: Int) { }
}
