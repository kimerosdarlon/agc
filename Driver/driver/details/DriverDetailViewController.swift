//
//  DriverDetailViewController.swift
//  Driver
//
//  Created by Samir Chaves on 15/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import ViewPager_Swift
import AgenteDeCampoModule
import AgenteDeCampoCommon

class DriverDetailViewController: UIViewController {
    private var details: Driver!
    private let tabHeader = DriverDetailHeaderView()
    private var headerHeightFlow: NSLayoutConstraint!
    private let expandedHeaderHeight = DriverDetailHeaderHeight.expanded.rawValue
    private let shrinkedHeaderHeight = DriverDetailHeaderHeight.shrinked.rawValue
    private var messageAlert = CustomMessageAlert()

    var alertBar = DriverAlertHeader()
    private var tabsView: DriverDetailTabsViewController!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init (withDriver details: Driver) {
        super.init(nibName: nil, bundle: nil)
        self.details = details
        tabsView = DriverDetailTabsViewController(withDriver: details)
        tabsView.delegate = self
        tabsView.generalDetailsDelegate = self
    }

    private let container: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.enableAutoLayout()
        view.backgroundColor = .appBackground
        return view
    }()

    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        alertBar.enableAutoLayout()
        tabHeader.enableAutoLayout()
        tabsView.view.enableAutoLayout()

        headerHeightFlow = tabHeader.heightAnchor.constraint(equalToConstant: CGFloat(expandedHeaderHeight))
        headerHeightFlow.isActive = true
        NSLayoutConstraint.activate([
            alertBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            alertBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            alertBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            tabHeader.topAnchor.constraint(equalTo: alertBar.bottomAnchor, constant: 10),
            tabHeader.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            tabHeader.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            tabsView.view.topAnchor.constraint(equalTo: tabHeader.bottomAnchor, constant: 5.0),
            tabsView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tabsView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            tabsView.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 15.0)
        ])
    }

    private func addSubviews() {
        view.addSubview(alertBar)
        view.addSubview(tabsView.view)
//        view.bringSubviewToFront(tabsView.view)
        view.addSubview(tabHeader)
        addChild(tabsView)
        tabsView.didMove(toParent: self)
    }

    override func viewDidLoad() {
        tabHeader.delegate = self
        alertBar.configure(driver: details)
        addSubviews()
        setupLayout()
        tabHeader.configure(withDriver: details)
        messageAlert.enableAutoLayout()
        messageAlert.configure(withText: details.general.currentCnh.cnhWarning?.description ?? "", inView: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        tabHeader.setTheme()
    }
}

extension DriverDetailViewController: DriverDetailsTabsViewDelegate {
    func didPageViewScroll(_ scrollView: UIScrollView) {
        let scrollTop = scrollView.contentOffset.y
        let headerHeight = (self.headerHeightFlow?.constant ?? 0) - scrollTop
        if headerHeight > expandedHeaderHeight {
            self.headerHeightFlow?.constant = expandedHeaderHeight
        } else if headerHeight < shrinkedHeaderHeight {
            self.headerHeightFlow?.constant = shrinkedHeaderHeight
        } else {
            self.headerHeightFlow?.constant = headerHeight
            scrollView.contentOffset.y = 0
        }

        self.view.layoutIfNeeded()
        tabHeader.layoutIfNeeded(withHeight: self.headerHeightFlow?.constant ?? expandedHeaderHeight)
    }
}

extension DriverDetailViewController: DriverDetailHeaderDelegate, DriverGeneralDetailDelegate {
    func showMessageAlert() {
        messageAlert.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.messageAlert.hide()
        }
    }

    func didTapOnAlertMessage() {
        showMessageAlert()
    }

    func didTapOnExpirationWarning() {
        showMessageAlert()
    }
}
