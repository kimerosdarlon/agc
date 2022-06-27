//
//  DispatchBarView+interaction[.swift
//  CAD
//
//  Created by Samir Chaves on 21/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

extension DispatchBarView {
    @objc internal func handleOccurrenceViewTap(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.occurrenceView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.occurrenceView.alpha = 0.6
            }
        } else if gesture.state == .ended {
            // Ensure that there is an occurrence dispatched and properly loaded
            guard currentOccurrenceDetails != nil else { return }

            Toast.presentThin(
                in: parentViewController,
                message: "Toque e segure para ver os detalhes da ocorrência.",
                duration: 2
            )
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.occurrenceView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.occurrenceView.alpha = 1
            }
        } else if gesture.state == .cancelled {
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.occurrenceView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.occurrenceView.alpha = 1
            }
        }
    }

    @objc internal func handleButtonTap(_ gesture: UILongPressGestureRecognizer) {
        // Ensure that there is an occurrence dispatched and properly loaded
        guard currentOccurrenceDetails != nil else { return }

        if gesture.state == .began {
            releaseDispatchView.transform = CGAffineTransform(translationX: 0, y: 0)
            delegate?.didOpenMenu()
            occurrenceView.fadeOut()
            releaseDispatchView.isHidden = false
            releaseDispatchView.alpha = 0.7
            changeStatusDragView.translate(x: 0, y: 0)
            changeStatusDragView.fadeIn()
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse]) {
                self.releaseDispatchView.transform = CGAffineTransform(translationX: -30, y: 0)
                self.releaseDispatchView.alpha = 0.3
            }
            statusBtn.scale(by: 1.5)
        } else if gesture.state == .ended {
            endButtonTap()
        }
    }

    internal func endButtonTap() {
        changeStatusDragView.translate(x: 0, y: changeStatusDragViewHeight)
        changeStatusDragView.fadeOut()
        delegate?.didCloseMenu()
        statusBtn.scale(by: 1)
        releaseDispatchView.fadeOut()
        releaseDispatchView.transform = CGAffineTransform(translationX: 0, y: 0)
        releaseDispatchView.alpha = 0
        releaseDispatchContainer.transform = CGAffineTransform(translationX: 0, y: 0)
        occurrenceView.fadeIn(duration: 0.2) {
            self.occurrenceView.isHidden = false
            self.occurrenceView.alpha = 1
        }
    }

    internal func decayDragging(distance: CGFloat, max: CGFloat, factor: CGFloat = 6/7) -> CGFloat {
        let decayedDistance = pow(distance, factor)
        return decayedDistance <= max ? decayedDistance : max
    }

    @objc internal func handleButtonDrag(_ gesture: UIPanGestureRecognizer) {
        // Ensure that there is an occurrence dispatched and properly loaded
        guard currentOccurrenceDetails != nil else { return }

        let velocity = gesture.velocity(in: self)
        let distance = gesture.translation(in: self)
        if gesture.state == .began {
            statusActionDone = false
            if abs(velocity.x) > abs(velocity.y) {
                btnDragDirection = .horizontal
            } else {
                btnDragDirection = .vertical
            }
        } else if gesture.state == .changed {
            if let direction = btnDragDirection {
                switch direction {
                case .horizontal:
                    let distance = distance.x < 0 ? abs(distance.x) : 0
                    let decayedDistance = decayDragging(distance: distance, max: 150, factor: 0.92)
                    statusBtn.transform = CGAffineTransform(translationX: -decayedDistance, y: 0).scaledBy(x: 1.5, y: 1.5)
                    releaseDispatchContainer.transform = CGAffineTransform(translationX: -decayedDistance, y: 0)
                    if decayedDistance >= 75 && !statusActionDone {
                        feedbackGenerator.impactOccurred()
                        statusActionDone = true
                        didReleaseDispatch()
                        btnDragDirection = nil
                        statusBtn.translate(x: 0, y: 0)
                        endButtonTap()
                    }
                case .vertical:
                    let distance = distance.y < 0 ? abs(distance.y) : 0
                    let decayedDistance = decayDragging(distance: distance, max: 108, factor: 0.95)
                    statusBtn.transform = CGAffineTransform(translationX: 0, y: -decayedDistance).scaledBy(x: 1.5, y: 1.5)
                    if decayedDistance >= 108 && !statusActionDone {
                        feedbackGenerator.impactOccurred()
                        statusActionDone = true
                        didUpdateDispatch()
                        btnDragDirection = nil
                        statusBtn.translate(x: 0, y: 0)
                        endButtonTap()
                    }
                }
            }
        } else if gesture.state == .ended {
            btnDragDirection = nil
            statusBtn.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
        }
    }

    internal func setupGestures() {
        let btnPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleButtonDrag(_:)))
        btnPanGesture.minimumNumberOfTouches = 1
        btnPanGesture.delegate = self
        statusBtn.addGestureRecognizer(btnPanGesture)

        let btnTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleButtonTap(_:)))
        btnTapGesture.minimumPressDuration = 0
        btnTapGesture.delegate = self
        statusBtn.addGestureRecognizer(btnTapGesture)

        let occurrenceViewTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleOccurrenceViewTap(_:)))
        occurrenceViewTapGesture.minimumPressDuration = 0
        occurrenceView.addGestureRecognizer(occurrenceViewTapGesture)

        let occurrenceViewLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleOccurrenceViewLongPress(_:)))
        occurrenceViewLongPressGesture.minimumPressDuration = 0.3
        occurrenceViewLongPressGesture.numberOfTouchesRequired = 1
        occurrenceViewLongPressGesture.allowableMovement = 50
        occurrenceViewLongPressGesture.delegate = self
        occurrenceView.addGestureRecognizer(occurrenceViewLongPressGesture)
    }
}
