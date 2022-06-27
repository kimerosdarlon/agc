//
//  GeneralAlertBalloon.swift
//  CAD
//
//  Created by Samir Chaves on 12/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class GeneralAlertBalloon: UIView {
    var expanded = true
    private var count: Int = 0
    private var generalAlertBalloonWidthConstraint: NSLayoutConstraint?
    private let generalAlertBalloonLabel = UILabel.build(withSize: 12, weight: .bold, color: .white, alignment: .right)
    private let generalAlertIcon: UIView = {
        let icon = UILabel.build(withSize: 9, weight: .bold, color: .appRedAlert, alignment: .center, text: "!")
        icon.layer.cornerRadius = 6.5
        icon.layer.masksToBounds = true
        icon.backgroundColor = .white
        return icon
    }()
    override func didMoveToSuperview() {
        backgroundColor = .appRedAlert
        layer.cornerRadius = 15
        layer.masksToBounds = true
        alpha = 0
        addSubview(generalAlertIcon)
        generalAlertIcon.centerY(view: self).left(mutiplier: 1.1).width(13).height(13)
        height(30)
        addSubview(generalAlertBalloonLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(expandGeneralAlertsBalloon))
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)

        generalAlertBalloonWidthConstraint = widthAnchor.constraint(equalToConstant: 155)
        generalAlertBalloonWidthConstraint?.isActive = true

        generalAlertBalloonLabel.centerY(view: self)
        generalAlertBalloonLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
    }

    func setCount(_ count: Int) {
        self.count = count
        if expanded {
            generalAlertBalloonLabel.text = "Alertas gerais (\(count))"
        } else {
            generalAlertBalloonLabel.text = "(\(count))"
        }
    }

    @objc func expandGeneralAlertsBalloon() {
        if count > 0 {
            expanded = true
            self.generalAlertBalloonLabel.text = "Alertas gerais (\(count))"
            UIView.transition(with: self.generalAlertBalloonLabel, duration: 0.3, options: [.transitionCrossDissolve], animations: nil, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0, options: [.layoutSubviews]) {
                self.generalAlertBalloonWidthConstraint?.constant = 155
                self.superview?.layoutIfNeeded()
            }
        }
    }

    func shrinkGeneralAlertsBalloon() {
        if count > 0 {
            expanded = false
            self.generalAlertBalloonLabel.text = "(\(count))"
            UIView.transition(with: self.generalAlertBalloonLabel, duration: 0.3, options: [.transitionCrossDissolve], animations: nil, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0) {
                self.generalAlertBalloonWidthConstraint?.constant = 60
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
