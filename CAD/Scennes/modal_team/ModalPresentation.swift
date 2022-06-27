//
//  ModalPresentation.swift
//  CAD
//
//  Created by Samir Chaves on 02/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

final class PresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    private var padding: UIEdgeInsets
    private var heightFactor: CGFloat
    init(padding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0), heightFactor: CGFloat = 0.5) {
        self.padding = padding
        self.heightFactor = heightFactor
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(padding: padding, heightFactor: heightFactor, presentedViewController: presented, presenting: source)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionDismissAnimator()
    }
}

final class ModalPresentationController: UIPresentationController {
    private var padding: UIEdgeInsets
    private var heightFactor: CGFloat
    var dimmingView: UIView!

    init(padding: UIEdgeInsets, heightFactor: CGFloat, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.padding = padding
        self.heightFactor = heightFactor
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.setupDimmingView()
    }

    func setupDimmingView() {
        self.dimmingView = UIView(frame: presentingViewController.view.bounds)
        self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ModalPresentationController.dimmingViewTapped(_:)))
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
        presentedView!.layer.cornerRadius = 15
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - (padding.left + padding.right), height: parentSize.height * heightFactor - (padding.bottom + padding.top))
    }

    override var frameOfPresentedViewInContainerView: CGRect {
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
        let containerBounds = self.containerView?.bounds ?? CGRect.zero
        let contentContainer = self.presentedViewController
        var presentedViewFrame = CGRect(origin: CGPoint.zero, size: self.size(forChildContentContainer: contentContainer, withParentContainerSize: containerBounds.size))
        presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2
        presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height) - bottomPadding + padding.top + padding.bottom

        return presentedViewFrame
    }
}

final class ModalTransitionPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
     return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let toViewController = transitionContext.viewController(forKey: .to)
    let containerView = transitionContext.containerView
    let animationDuration = self.transitionDuration(using: transitionContext)

    toViewController?.view.transform = CGAffineTransform(
        translationX: 0,
        y: containerView.frame.size.height
    )
    containerView.addSubview((toViewController?.view)!)

    UIView.animate(withDuration: animationDuration, animations: { () -> Void in
      toViewController?.view.transform = CGAffineTransform.identity
    }, completion: { (finished) -> Void in
      transitionContext.completeTransition(finished)
    })
  }
}

final class ModalTransitionDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let fromViewController = transitionContext.viewController(forKey: .from)!
    let containerView = transitionContext.containerView
    let animationDuration = self.transitionDuration(using: transitionContext)

    UIView.animate(withDuration: animationDuration, animations: { () -> Void in
      fromViewController.view.alpha = 0.0
      fromViewController.view.transform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height)
    }, completion: { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
  }
}
