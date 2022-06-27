//
//  WarrantDetailViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import ViewPager_Swift
import AgenteDeCampoCommon
import MaterialComponents

class WarrantDetailViewController: UIViewController {

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    var viewControllers = [UIViewController]()
    let service = WarrantService()
    var warrant: Warrant
    let pagerOptions = AppDefaults().pagerOptions
    var viewPager: ViewPager!

    fileprivate let viewPagerContent: UIView = {
        let view = UIView()
        view.enableAutoLayout()
        view.backgroundColor = .appBackground
        return view
    }()

    private var headerviewController: WarrantDetailHeader!

    init(with warrant: Warrant) {
        self.warrant = warrant
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewPager = ViewPager(viewController: self, containerView: viewPagerContent)
        viewPager.setOptions(options: pagerOptions)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.enableAutoLayout()
        activityIndicator.fillSuperView()
        service.getDetails(warrant) { (result) in
            switch result {
            case .success(let details):
                self.handlerSuccess(details)
            case .failure(let error):
                self.handlerRequestError(error) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        view.backgroundColor = .appBackground
    }

    func handlerSuccess(_ details: WarrantDetails) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.title = details.piece.type.name
            self.viewControllers = [
                PersonalDataViewController(personalData: details.personal),
                PieceViewController(piece: details.piece),
                SentenceViewController(sentence: details.sentence),
                ExpeditionViewController(expedidtion: details.expedition),
                PrisionViewController(prision: details.prison)
            ]
            self.viewPager.setDataSource(dataSource: self)
            self.viewPager.setDelegate(delegate: self)
            self.headerviewController = WarrantDetailHeader(details: details)
            self.viewPager.build()
            self.addSubviews()
            self.setupConstraints()
        }
    }

    func addSubviews() {
        view.addSubview(headerviewController.view)
        view.addSubview(viewPagerContent)
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let headerView = headerviewController.view!
        headerView.enableAutoLayout()
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 250),
            viewPagerContent.topAnchor.constraint(equalToSystemSpacingBelow: headerView.bottomAnchor, multiplier: 1),
            viewPagerContent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewPagerContent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewPagerContent.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension WarrantDetailViewController: ViewPagerDataSource, ViewPagerDelegate {

    func numberOfPages() -> Int {
        return viewControllers.count
    }

    func viewControllerAtPosition(position: Int) -> UIViewController {
        return viewControllers[position]
    }

    func tabsForPages() -> [ViewPagerTab] {
        return viewControllers.map { (controler) -> ViewPagerTab in
            return ViewPagerTab(title: controler.title!, image: nil)
        }
    }

    func startViewPagerAtIndex() -> Int {
        return 0
    }

    func willMoveToControllerAtIndex(index: Int) {

    }

    func didMoveToControllerAtIndex(index: Int) {

    }

}
