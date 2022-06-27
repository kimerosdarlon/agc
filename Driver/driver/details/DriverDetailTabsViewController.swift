//
//  DriverDetailTabsViewController.swift
//  Driver
//
//  Created by Samir Chaves on 22/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import ViewPager_Swift
import AgenteDeCampoModule
import AgenteDeCampoCommon

class DriverDetailTabsViewController: UIViewController {
    var viewPager: ViewPager!
    var details: Driver!
    weak var delegate: DriverDetailsTabsViewDelegate?
    weak var generalDetailsDelegate: DriverGeneralDetailDelegate?
    private var initialPage = 0

    var controllers = [UIViewController]()

    required init?(coder: NSCoder) {
        fatalError()
    }

    init (withDriver details: Driver) {
        super.init(nibName: nil, bundle: nil)
        self.details = details
    }

    private let pagerOptions: ViewPagerOptions = {
        let option = AppDefaults().pagerOptions
        option.tabViewHeight = 45
        option.distribution = .segmented
        option.tabViewPaddingLeft = 10
        option.tabViewTextFont = UIFont.systemFont(ofSize: 15.0)
        option.shadowOpacity = 0.1
        return option
    }()

    override func viewDidLoad() {
        let general = DriverGeneralDetailViewController(with: details)
        general.delegate = delegate
        general.detailsDelegate = generalDetailsDelegate
        let individual = DriverIndividualDetailViewController(with: details.individual)
        individual.delegate = delegate
        let occurrences = DriverOccurrencesDetailViewController(with: details.occurrences)
        occurrences.delegate = delegate
        controllers.append(contentsOf: [general, individual, occurrences])

        viewPager = ViewPager(viewController: self)
        viewPager.setOptions(options: pagerOptions)
        viewPager.setDataSource(dataSource: self)
        viewPager.setDelegate(delegate: self)
        viewPager.build()

        view.height(1000)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserStylePreferences.theme.style == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .systemGray5
        }
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension DriverDetailTabsViewController: ViewPagerDataSource, ViewPagerDelegate {

    func numberOfPages() -> Int { controllers.count }

    func viewControllerAtPosition(position: Int) -> UIViewController { controllers[position] }

    func tabsForPages() -> [ViewPagerTab] {
        return controllers.map({ ViewPagerTab(title: $0.title ?? "Sem título", image: nil) })
    }

    func startViewPagerAtIndex() -> Int { initialPage }

    func willMoveToControllerAtIndex(index: Int) { }

    func didMoveToControllerAtIndex(index: Int) { }
}
