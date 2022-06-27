//
//  UIView+AgenteCampo.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 22/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public extension UIView {

    @discardableResult
    func enableAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    @discardableResult
    func top(_ view: UIView, mutiplier: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: mutiplier)
        ])
        return self
    }

    @discardableResult
    func top(to anchor: NSLayoutYAxisAnchor, mutiplier: CGFloat) -> Self {
        topAnchor.constraint(equalToSystemSpacingBelow: anchor, multiplier: mutiplier).isActive = true
        return self
    }

    @discardableResult
    func left(_ view: UIView, mutiplier: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: mutiplier)
        ])
        return self
    }

    @discardableResult
    func left(_ anchor: NSLayoutXAxisAnchor, mutiplier: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalToSystemSpacingAfter: anchor, multiplier: mutiplier)
        ])
        return self
    }

    @discardableResult
    func top(mutiplier: CGFloat) -> Self {
        guard let view = self.superview else {
            NSLog("Superview is null")
            return self
        }
        return self.top(view, mutiplier: mutiplier)
    }

    @discardableResult
    func left(mutiplier: CGFloat) -> Self {
        guard let view = self.superview else {
            NSLog("Superview is null")
            return self
        }
        return self.left(view, mutiplier: mutiplier)
    }

    @discardableResult
    func width(_ value: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: value)
        ])
        return self
    }

    @discardableResult
    func width(_ view: UIView) -> Self {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
        ])
        return self
    }

    @discardableResult
    func width(_ dimension: NSLayoutDimension, multiplier: CGFloat = 1 ) -> Self {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: dimension, multiplier: multiplier)
        ])
        return self
    }

    @discardableResult
    func height(_ value: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: value)
        ])
        return self
    }

    @discardableResult
    func height(_ view: UIView) -> Self {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
        ])
        return self
    }

    @discardableResult
    func box(_ value: CGFloat) -> Self {
        return height(value).width(value)
    }

    @discardableResult
    func centerX(view: UIView) -> Self {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        return self
    }

    @discardableResult
    func centerX() -> Self {
        if let view = superview {
            NSLayoutConstraint.activate([
                centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
        return self
    }

    @discardableResult
    func centerY() -> Self {
        if let view = superview {
            NSLayoutConstraint.activate([
                centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        return self
    }

    @discardableResult
    func centerY(view: UIView) -> Self {
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return self
    }

    @discardableResult
    func fillSuperView(regardSafeArea: Bool = false) -> Self {
        if let view = superview {
            if regardSafeArea {
                NSLayoutConstraint.activate([
                    topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1),
                    leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
                    view.trailingAnchor.constraint(equalToSystemSpacingAfter: trailingAnchor, multiplier: 1),
                    view.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomAnchor, multiplier: 1)
                ])
                return self
            }
            return width(view).height(view).centerX().centerY()
        }
        return self
    }

    func bottom(_ value: CGFloat) -> Self {
        if let view = superview {
            NSLayoutConstraint.activate([
                bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: value)
            ])
        }
        return self
    }

    @discardableResult
    func bottom(to anchor: NSLayoutYAxisAnchor, _ value: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalToSystemSpacingBelow: anchor, multiplier: value)
        ])
        return self
    }

    @discardableResult
    func right(_ value: CGFloat) -> Self {
        if let view = superview {
            NSLayoutConstraint.activate([
                trailingAnchor.constraint(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: value)
            ])
        }
        return self
    }

    @discardableResult
    func right(to anchor: NSLayoutXAxisAnchor, _ value: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalToSystemSpacingAfter: anchor, multiplier: value)
        ])
        return self
    }

    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }

    func fadeIn(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        self.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }

    func fadeOut(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        if !self.isHidden {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 0
            }, completion: { _ in
                completion?()
                self.isHidden = true
            })
        }
    }

    func scale(by scale: CGFloat = 1, duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }

    func translate(x translateX: CGFloat = 0, y translateY: CGFloat = 0, duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(translationX: translateX, y: translateY)
        })
    }
    
    var isAnimating: Bool {
        return (self.layer.animationKeys()?.count ?? 0) > 0
    }
}

public extension UIView {

    @discardableResult
    func circle() -> Self {
        self.layer.cornerRadius = frame.width * 0.5
        self.layer.masksToBounds = true
        return self
    }

    @discardableResult
    func float() -> Self {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 2.0
        layer.masksToBounds = false
        layer.cornerRadius = 4.0
        return self
    }

    static func spacer() -> UIView {
        return UIView()
    }
}

public extension UIView {
    func shake() {
        self.transform = CGAffineTransform(rotationAngle: 0.04)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
