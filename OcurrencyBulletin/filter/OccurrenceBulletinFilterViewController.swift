//
//  OccurrenceBulletinFilterViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 21/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import ViewPager_Swift
import AgenteDeCampoModule
import AgenteDeCampoCommon
import CoreDataModels

class OccurrenceBulletinFilterViewController: UIViewController, ModuleFilterViewControllerProtocol {

    weak var delegate: SearchDelegate?
    var objectFilter: ObjectFilterViewController
    var nationalFilter: NationalCodeBulletinFilterViewController
    var involvedFilter: InvolvedFilterViewController
    var controllers = [ModuleFilterViewControllerProtocol]()

    let pagerOptions: ViewPagerOptions = {
        let option = ViewPagerOptions()
        option.viewPagerTransitionStyle = .scroll
        option.tabType = .basic
        option.tabViewHeight = 40
        option.tabIndicatorViewBackgroundColor = .appBlue
        option.tabViewTextDefaultColor = .appCellLabel
        option.tabViewPaddingLeft = 20
        option.distribution = .segmented
        option.tabViewTextHighlightColor = .appBackgroundCell
        option.tabViewBackgroundDefaultColor = .appBackground
        option.isTabHighlightAvailable = false
        return option
    }()

    var viewPager: ViewPager!
    private var initialPage = 0

    private var params: [String: Any]

    var stateDataSource = StateDataSource() {
        didSet {
            nationalFilter.stateDataSource = stateDataSource
            objectFilter.stateDataSource = stateDataSource
            involvedFilter.stateDataSource = stateDataSource
        }
    }

    var serviceType: ServiceType {
        guard let service = self.params["service"] as? String else { return .physical }
        return ServiceType.init(rawValue: service) ?? .physical
    }

    required init(params: [String: Any]) {
        self.params = params
        nationalFilter = NationalCodeBulletinFilterViewController(params: params)
        involvedFilter = InvolvedFilterViewController(params: params)
        objectFilter = ObjectFilterViewController(params: params)

        nationalFilter.stateDataSource = stateDataSource
        objectFilter.stateDataSource = stateDataSource
        involvedFilter.stateDataSource = stateDataSource
        super.init(nibName: nil, bundle: nil)
        switch self.serviceType {
        case .national, .state:
            initialPage = 0
        case .legal, .physical:
            initialPage = 1
        case .cellphones, .weapons, .vehicle:
            initialPage = 2
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        controllers.append(contentsOf: [nationalFilter, involvedFilter])
        controllers.append(objectFilter)
        viewPager = ViewPager(viewController: self)
        viewPager.setOptions(options: pagerOptions)
        self.viewPager.setDataSource(dataSource: self)
        self.viewPager.setDelegate(delegate: self)
        viewPager.build()
        title = "Boletins de Ocorrência"
        for controller in controllers {
            controller.delegate = delegate
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension OccurrenceBulletinFilterViewController: ViewPagerDataSource, ViewPagerDelegate {

    func numberOfPages() -> Int { controllers.count }

    func viewControllerAtPosition(position: Int) -> UIViewController { controllers[position] }

    func tabsForPages() -> [ViewPagerTab] {
        return controllers.map({ ViewPagerTab(title: $0.title ?? "Sem título", image: nil) })
    }

    func startViewPagerAtIndex() -> Int { initialPage }

    func willMoveToControllerAtIndex(index: Int) { }

    func didMoveToControllerAtIndex(index: Int) { }
}
