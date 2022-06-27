//
//  ToastPresentation.swift
//  CAD
//
//  Created by Samir Chaves on 24/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

final class ToastPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    private let width: CGFloat

    init(width: CGFloat) {
        self.width = width
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ToastModalPresentationController(presentedViewController: presented, presenting: source, withWidth: width)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ToastModalTransitionPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ToastModalTransitionDismissAnimator()
    }
}

final class ToastModalPresentationController: UIPresentationController {

    var dimmingView: UIView!
    private let width: CGFloat

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, withWidth width: CGFloat) {
        self.width = width
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.setupDimmingView()
    }

    func setupDimmingView() {
        self.dimmingView = UIView(frame: presentingViewController.view.bounds)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ToastModalPresentationController.dimmingViewTapped(_:)))
        self.dimmingView.addGestureRecognizer(tapRecognizer)
    }

    @objc func dimmingViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        let containerView = self.containerView
        let presentedViewController = self.presentedViewController

        self.dimmingView.frame = self.frameOfPresentedViewInContainerView
        self.dimmingView.alpha = 0.0

        containerView!.insertSubview(self.dimmingView, at: 0)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 1.0
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 0.0
        }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        self.dimmingView.frame = containerView!.bounds
        presentedView!.frame = self.frameOfPresentedViewInContainerView
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        print(container)
        return .zero
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let containerBounds = self.containerView?.bounds ?? CGRect.zero
        let contentContainer = self.presentedViewController
        let contentView = contentContainer.view
        var responsiveWidth = width
        if width > containerBounds.width && containerBounds.width != 0 {
            responsiveWidth = containerBounds.width * 0.95
        }
        contentView?.width(responsiveWidth)
        var presentedViewFrame = CGRect(origin: .zero, size: CGSize(width: responsiveWidth, height: contentContainer.view.bounds.height))
        presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2
        presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height)  / 2

        return presentedViewFrame
    }
}

final class ToastModalTransitionPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)
        let containerView = transitionContext.containerView
        let animationDuration = self.transitionDuration(using: transitionContext)

        toViewController?.view.alpha = 0
        containerView.addSubview((toViewController?.view)!)
        containerView.isUserInteractionEnabled = false

        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            toViewController?.view.alpha = 1
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(finished)
        })
    }
}

final class ToastModalTransitionDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let animationDuration = self.transitionDuration(using: transitionContext)

        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            fromViewController.view.alpha = 0.0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
