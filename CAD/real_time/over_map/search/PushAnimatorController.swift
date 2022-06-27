//
//  PushAnimatorController.swift
//  CAD
//
//  Created by Samir Chaves on 06/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class PushAnimatorController: NSObject {
    enum AnimationType {
        case present, dismiss
    }

    private let duration: TimeInterval
    private let animationType: AnimationType

    init(duration: TimeInterval, animationType: AnimationType) {
        self.duration = duration
        self.animationType = animationType
    }
}

extension PushAnimatorController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        switch animationType {
        case .dismiss:
            transitionContext.containerView.addSubview(fromViewController.view)
            dismissAnimation(transitionContext: transitionContext, viewToAnimate: fromViewController.view)
        case .present:
            transitionContext.containerView.addSubview(toViewController.view)
            presentAnimation(transitionContext: transitionContext, viewToAnimate: toViewController.view)
        }
    }

    func presentAnimation(transitionContext: UIViewControllerContextTransitioning, viewToAnimate view: UIView) {
        view.clipsToBounds = true
        view.alpha = 0

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }

    func dismissAnimation(transitionContext: UIViewControllerContextTransitioning, viewToAnimate view: UIView) {
        view.clipsToBounds = true
        view.alpha = 1

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
