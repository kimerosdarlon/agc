//
//  OccurrencePagerViewController.swift
//  CAD
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import ViewPager_Swift

class OccurrencePagerViewController: SecureViewController {
    weak var updateDelegate: OccurrenceDataUpdateDelegate? {
        didSet {
            general.updateDelegate = updateDelegate
            vehicles.updateDelegate = updateDelegate
            involved.updateDelegate = updateDelegate
            weapons.updateDelegate = updateDelegate
            drugs.updateDelegate = updateDelegate
        }
    }

    var details: OccurrenceDetails
    var viewPager: ViewPager!
    private var initialPage = 0

    var controllers = [UIViewController]()

    required init?(coder: NSCoder) {
        fatalError()
    }

    private let general: OccurrenceGeneralDetailViewController
    private let history: UIViewController
    private let dispatches: UIViewController
    private let vehicles: ObjectDetailsViewController
    private let involved: ObjectDetailsViewController
    private let weapons: ObjectDetailsViewController
    private let drugs: ObjectDetailsViewController
    private let linked: UIViewController
    private let complementary: UIViewController

    init (occurrence: OccurrenceDetails) {
        self.details = occurrence
        general = OccurrenceGeneralDetailViewController(occurrence: details)
        history = OccurrenceHistoryViewController(details: details)
        dispatches = OccurrenceDispatchesDetailViewController(with: details)
        vehicles = OccurrenceVehiclesDetailViewController(with: details)
        involved = OccurrenceInvolvedViewController(with: details)
        weapons = OccurrenceWeaponsViewController(with: details)
        drugs = OccurrenceDrugsViewController(with: details)

        let linkedEmptyFeedback = "Nenhuma outra ocorrência foi vinculada a esta."
        linked = LinkedOccurrencesViewController(
            with: details.linked,
            mainOccurrence: details,
            title: "Vinculados",
            emptyFeedback: linkedEmptyFeedback
        )
        let complementaryEmptyFeedback = "Nenhuma ocorrência complementar encontrada."
        complementary = LinkedOccurrencesViewController(
            with: details.complementary,
            mainOccurrence: details,
            title: "Complementares",
            emptyFeedback: complementaryEmptyFeedback
        )
        super.init(nibName: nil, bundle: nil)
    }

    private let pagerOptions: ViewPagerOptions = {
        let option = AppDefaults().pagerOptions
        option.tabViewHeight = 45
        option.distribution = .normal
        option.tabViewPaddingLeft = 10
        option.tabViewTextFont = UIFont.systemFont(ofSize: 15.0)
        option.shadowOpacity = 0.1
        return option
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        controllers.append(
            contentsOf: [general, dispatches, vehicles, involved, weapons, drugs, linked, complementary, history]
        )

        viewPager = ViewPager(viewController: self)
        viewPager.setOptions(options: pagerOptions)
        viewPager.setDataSource(dataSource: self)
        viewPager.setDelegate(delegate: self)
        viewPager.build()

        view.backgroundColor = .appBackground
        view.height(1000)
        view.layer.masksToBounds = true
    }
}

extension OccurrencePagerViewController: ViewPagerDataSource, ViewPagerDelegate {

    func numberOfPages() -> Int { controllers.count }

    func viewControllerAtPosition(position: Int) -> UIViewController { controllers[position] }

    func tabsForPages() -> [ViewPagerTab] {
        return controllers.map({ ViewPagerTab(title: $0.title ?? "Sem título", image: nil) })
    }

    func startViewPagerAtIndex() -> Int { initialPage }

    func willMoveToControllerAtIndex(index: Int) { }

    func didMoveToControllerAtIndex(index: Int) { }
}
