//
//  SearchPresentation.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 21/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public final class SearchPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SearchModalPresentationController(presentedViewController: presented, presenting: source)
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SearchModalTransitionPresentationAnimator()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SearchModalTransitionDismissAnimator()
    }
}

final class SearchModalPresentationController: UIPresentationController {

  var dimmingView: UIView!

  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    self.setupDimmingView()
  }

  func setupDimmingView() {
    self.dimmingView = UIView(frame: presentingViewController.view.bounds)

    let visualEffectView = UIVisualEffectView()
    visualEffectView.effect = UIBlurEffect(style: .systemChromeMaterial)
    visualEffectView.frame = dimmingView.bounds
    visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    self.dimmingView.addSubview(visualEffectView)

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchModalPresentationController.dimmingViewTapped(_:)))
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
    return CGSize(width: parentSize.width, height: parentSize.height / 1.25)
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    let containerBounds = self.containerView?.bounds ?? CGRect.zero
    let contentContainer = self.presentedViewController
    var presentedViewFrame = CGRect(origin: CGPoint.zero, size: self.size(forChildContentContainer: contentContainer, withParentContainerSize: containerBounds.size))
    presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2
    presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height)

    return presentedViewFrame
  }
}

final class SearchModalTransitionPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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

final class SearchModalTransitionDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

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
