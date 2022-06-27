//
//  OccurrenceDetailNavigationController.swift
//  CAD
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public class OccurrenceDetailNavigationController: UINavigationController {
    private let occurrenceViewController: OccurrenceDetailViewController
    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    public init(occurrence: OccurrenceDetails) {
        occurrenceViewController = OccurrenceDetailViewController(occurrence: occurrence)

        super.init(rootViewController: occurrenceViewController)

        modalPresentationStyle = .custom
        transitionDelegate = DefaultModalPresentationManager(heightFactor: 0.9, position: .center)
        transitioningDelegate = transitionDelegate
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = .appBackground
        standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appTitle]
        navigationBar.standardAppearance = standardAppearance
        navigationBar.barStyle = .black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
