//
//  DriverDetailPageViewController.swift
//  Driver
//
//  Created by Samir Chaves on 27/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import AgenteDeCampoModule

class DriverDetailPageViewController: UIViewController {
    weak var delegate: DriverDetailsTabsViewDelegate?

    lazy var scrollContainer: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.enableAutoLayout()
        return scroll
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        scrollContainer.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        scrollContainer.contentOffset.y = 0
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension DriverDetailPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didPageViewScroll(scrollView)
    }
}
