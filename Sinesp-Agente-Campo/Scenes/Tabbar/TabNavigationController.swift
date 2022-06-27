//
//  TabViewController.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 23/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class TabNavigationController: UINavigationController {
    private let rootNavigation: UINavigationController
    private let blurOverlay: UIView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = false
        view.alpha = 0
        return view
    }()
    private var bottomConstraint: NSLayoutConstraint?
    private var footerHidden = true

    init(rootNavigation: UINavigationController) {
        self.rootNavigation = rootNavigation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showFooter() {
        footerHidden = false
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint?.constant = -TabBarController.bottomBarHeight
            self.view.layoutIfNeeded()
        }
    }

    func hideFooter() {
        footerHidden = true
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    func blur() {
        UIView.animate(withDuration: 0.2) {
            self.blurOverlay.alpha = 0.8
        }
    }

    func focus() {
        UIView.animate(withDuration: 0.2) {
            self.blurOverlay.alpha = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarHidden(true, animated: false)
        let topPadding = view.safeAreaInsets.top
        view.addSubview(rootNavigation.view.enableAutoLayout())
        view.addSubview(blurOverlay)
        NSLayoutConstraint.activate([
            rootNavigation.view.topAnchor.constraint(equalTo: view.topAnchor, constant: -topPadding),
            rootNavigation.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootNavigation.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        blurOverlay.frame = rootNavigation.view.bounds
        if footerHidden {
            bottomConstraint = rootNavigation.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        } else {
            bottomConstraint = rootNavigation.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -TabBarController.bottomBarHeight)
        }
        bottomConstraint?.isActive = true
        addChild(rootNavigation)
        rootNavigation.didMove(toParent: self)
    }
}
