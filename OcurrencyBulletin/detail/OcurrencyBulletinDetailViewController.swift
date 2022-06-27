//
//  OcurrencyBulletinDetailViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import ViewPager_Swift
import AgenteDeCampoCommon

class OcurrencyBulletinDetailViewController: UIViewController {

    let pagerOptions = AppDefaults().pagerOptions
    var viewPager: ViewPager!
    var controlers = [UIViewController]()
    let viewModel: OcurrencyBulletinDetailViewModel

    init(viewModel: OcurrencyBulletinDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var hasVehicles: Bool { !viewModel.vehicles.isEmpty }
    var hasWeaposns: Bool { !viewModel.weapons.isEmpty }
    var hasCellphones: Bool { !viewModel.cellphones.isEmpty }
    var hasOthers: Bool { !viewModel.others.isEmpty }
    var hasInvolveds: Bool { !viewModel.involveds.isEmpty }
    var hasDrugs: Bool { !viewModel.drugs.isEmpty }
    var hasDocuments: Bool { !viewModel.documents.isEmpty }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewPager = ViewPager(viewController: self)
        viewPager.setDelegate(delegate: self)
        viewPager.setDataSource(dataSource: self)
        viewPager.setOptions(options: self.pagerOptions)
        controlers.append( BulletinBasicDataViewController(viewModel: viewModel) )
        controlers.appendIf( hasInvolveds, BulletinInvolvedViewController(viewModel: viewModel) )
        controlers.appendIf( hasVehicles, BulletinVehicleViewController(viewModel: viewModel))
        controlers.appendIf( hasWeaposns, BulletinWeaponDetailViewController(viewModel: viewModel) )
        controlers.appendIf( hasCellphones, CellPhoneDetailViewController(viewModel: viewModel))
        controlers.appendIf( hasOthers, OtherObjectsDetailViewController(viewModel: viewModel))
        controlers.appendIf( hasDocuments, DocumentsDetailViewController(viewModel: viewModel) )
        controlers.appendIf( hasDrugs, DrugsDetailViewController(viewModel: viewModel) )
        title = self.viewModel.codeNational
        viewPager.build()
        view.backgroundColor = .appBackground
    }
}

extension OcurrencyBulletinDetailViewController: ViewPagerDelegate, ViewPagerDataSource {

    func willMoveToControllerAtIndex(index: Int) { }

    func didMoveToControllerAtIndex(index: Int) { }

    func numberOfPages() -> Int { controlers.count }

    func viewControllerAtPosition(position: Int) -> UIViewController {  controlers[position] }

    func tabsForPages() -> [ViewPagerTab] {
        return controlers.map({ ViewPagerTab(title: $0.title ?? "", image: nil) })
    }

    func startViewPagerAtIndex() -> Int { 0 }
}
