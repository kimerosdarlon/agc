//
//  DefaultModalPresentation.swift
//  CAD
//
//  Created by Samir Chaves on 04/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

final class DefaultModalPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    private let widthFactor: CGFloat
    private let heightFactor: CGFloat
    private let position: ModalPosition

    enum ModalPosition {
        case bottom, center
    }

    init(widthFactor: CGFloat = 0.925, heightFactor: CGFloat = 0.8, position: ModalPosition = .center) {
        self.widthFactor = widthFactor
        self.heightFactor = heightFactor
        self.position = position
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DefaultModalPresentationController(
            widthFactor: widthFactor,
            heightFactor: heightFactor,
            position: position,
            presentedViewController: presented,
            presenting: source
        )
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DefaultModalTransitionPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DefaultModalTransitionDismissAnimator()
    }
}

final class DefaultModalPresentationController: UIPresentationController {
    private let widthFactor: CGFloat
    private let heightFactor: CGFloat
    private let position: DefaultModalPresentationManager.ModalPosition
    var dimmingView: UIView!

    init(widthFactor: CGFloat,
         heightFactor: CGFloat,
         position: DefaultModalPresentationManager.ModalPosition,
         presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?) {
        self.widthFactor = widthFactor
        self.heightFactor = heightFactor
        self.position = position
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.setupDimmingView()
    }

    func setupDimmingView() {
        self.dimmingView = UIView(frame: presentingViewController.view.bounds)

        let visualEffectView = UIVisualEffectView()
        visualEffectView.effect = UIBlurEffect(style: .systemChromeMaterialDark)
        visualEffectView.frame = dimmingView.bounds
        visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.dimmingView.addSubview(visualEffectView)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DefaultModalPresentationController.dimmingViewTapped(_:)))
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
        return CGSize(width: parentSize.width * widthFactor, height: parentSize.height * heightFactor)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let containerBounds = self.containerView?.bounds ?? CGRect.zero
        let contentContainer = self.presentedViewController
        let contentView = contentContainer.view
        contentView?.layer.cornerRadius = 10
        contentView?.layer.masksToBounds = true
        var presentedViewFrame = CGRect(origin: CGPoint.zero, size: self.size(forChildContentContainer: contentContainer, withParentContainerSize: containerBounds.size))
        switch position {
        case .center:
            presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2
            presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height)  / 2
        case .bottom:
            var bottomPadding: CGFloat = 0
            if #available(iOS 11.0, *) {
                if let window = UIApplication.shared.keyWindow {
                    bottomPadding = window.safeAreaInsets.bottom
                }
            }
            if #available(iOS 13.0, *) {
                if let window = UIApplication.shared.windows.first {
                    bottomPadding = window.safeAreaInsets.bottom
                }
            }
            presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2
            presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height - bottomPadding
        }

        return presentedViewFrame
    }
}

final class DefaultModalTransitionPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)
        let containerView = transitionContext.containerView
        let animationDuration = self.transitionDuration(using: transitionContext)

        toViewController?.view.alpha = 0
        toViewController?.view.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
        containerView.addSubview((toViewController?.view)!)

        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            toViewController?.view.alpha = 1
            toViewController?.view.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(finished)
        })
    }
}

final class DefaultModalTransitionDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let animationDuration = self.transitionDuration(using: transitionContext)

        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            fromViewController.view.alpha = 0.0
            fromViewController.view.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
