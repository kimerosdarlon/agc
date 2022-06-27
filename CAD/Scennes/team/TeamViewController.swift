//
//  TeamViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 05/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import ViewPager_Swift
import AgenteDeCampoCommon

public class TeamViewController: UIViewController {

    private var pagerConfiguration: ViewPagerOptions = {
        let configuration = AppDefaults().pagerOptions
        configuration.distribution = .segmented
        return configuration
    }()

    @CadServiceInject
    private var cadService: CadService

    private let activiteIndicator = UIActivityIndicatorView(style: .large)

    private var teams = [Team]()

    private var subViewController: UIViewController?

    private lazy var refreshButton: UIBarButtonItem = {
        let refreshImage = UIImage(systemName: "arrow.clockwise")
        let customView = UIButton(frame: .init(x: 0, y: 0, width: 60, height: 50))
        customView.setImage(refreshImage, for: .normal)
        let button = UIBarButtonItem(customView: customView)
        customView.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        return button
    }()

    private var viewPager: ViewPager!

    @CadServiceInject
    private var service: CadService

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buildController() {
        garanteeMainThread {
            let controller: UIViewController!
            if self.service.hasActiveTeam() {
                let viewModel = CadResourceViewModel(team: self.service.getActiveTeam()!, andDispatches: self.service.getDispatches())
                controller = ActiveTeamViewController(team: viewModel)
            } else {
                controller = TeamScheduleViewController()
            }
            self.title = "Equipes"
            self.navigationItem.rightBarButtonItem = self.refreshButton
            self.subViewController?.willMove(toParent: nil)
            self.subViewController?.view.removeFromSuperview()
            self.subViewController?.removeFromParent()

            self.addChild(controller)
            self.view.addSubview(controller.view)
            controller.didMove(toParent: self)

            controller.view.enableAutoLayout()
            controller.view.fillSuperView()
            self.subViewController = controller
        }
    }

    public override func viewDidLoad() {
        view.backgroundColor = .appBackground
//        title = "Equipe"
//        viewPager = ViewPager(viewController: self)
//        viewPager.setDataSource(dataSource: self)
//        viewPager.setOptions(options: pagerConfiguration)
        self.buildController()
        NotificationCenter.default.addObserver(self, selector: #selector(buildController), name: .cadResourceDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func startRefreshingAnimation() {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.repeat], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.refreshButton.customView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 0.001)
            }

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.refreshButton.customView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2 - 0.001)
            }
        }, completion: { _ in
            self.refreshButton.customView?.transform = CGAffineTransform(rotationAngle: 0)
        })
    }

    private func stopRefreshingAnimation() {
        refreshButton.customView?.layer.removeAllAnimations()
    }

    @objc
    private func refresh() {
        self.startRefreshingAnimation()
        self.cadService.refreshResource { error in
            garanteeMainThread {
                if let error = error as NSError?, self.isUnauthorized(error) {
                    self.gotoLogin(error.domain)
                } else {
                    self.stopRefreshingAnimation()
                    self.buildController()
                }
            }
        }
    }

    private func getTeams() {
//        setupLoadingState()
        self.teams = service.getScheduledTeams()
//        self.stopLoading()
        self.buildController()
    }

    func setupLoadingState() {
        view.addSubview(activiteIndicator)
        activiteIndicator.enableAutoLayout().fillSuperView()
        activiteIndicator.startAnimating()
    }

    func stopLoading() {
        activiteIndicator.stopAnimating()
        activiteIndicator.removeFromSuperview()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        subViewController?.view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

// extension TeamViewController: ViewPagerDataSource, ViewPagerDelegate {
//     public func numberOfPages() -> Int { 2 }
// 
//     public func viewControllerAtPosition(position: Int) -> UIViewController {
//         if position == 0 && service.hasTeamActive() {
//             let viewModel = CadResourceViewModel(team: service.getActiveTeam()!.resource.activeTeam! )
//             return ActiveTeamViewController(team: viewModel)
//         } else if position == 0 {
//             return TeamScheduleViewController(scheduledTeams: self.teams)
//         }
//         let controller = TeamTemplateViewController(templates: [])
//         controller.view.backgroundColor = .appBackground
//         return controller
//     }
// 
//     public func tabsForPages() -> [ViewPagerTab] {
//         var tabs = [ViewPagerTab]()
//         tabs.appendIf(service.hasTeamActive(), ViewPagerTab(title: "Equipe Ativa", image: nil))
//         tabs.appendIf(!service.hasTeamActive(), ViewPagerTab(title: "Agendadas", image: nil))
//         tabs.append(ViewPagerTab(title: "Modelos", image: nil))
//         return tabs
//     }
// 
//     public func startViewPagerAtIndex() -> Int { 0 }
// 
//     public func willMoveToControllerAtIndex(index: Int) {}
// 
//     public func didMoveToControllerAtIndex(index: Int) {}
// }
