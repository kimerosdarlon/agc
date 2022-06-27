//
//  DispatchReleaseViewController.swift
//  CAD
//
//  Created by Samir Chaves on 01/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class DispatchReleaseNavigationController: UINavigationController {
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    
    init(teamId: UUID, occurrenceId: UUID) {
        let releaseDescriptionPicker = ReleaseDescriptionViewController(teamId: teamId, occurrenceId: occurrenceId)
        super.init(rootViewController: releaseDescriptionPicker)
        modalPresentationStyle = .custom

        transitionDelegate = DefaultModalPresentationManager(heightFactor: 0.85, position: .center)
        transitioningDelegate = transitionDelegate
    }

    override func viewDidLoad() {
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
