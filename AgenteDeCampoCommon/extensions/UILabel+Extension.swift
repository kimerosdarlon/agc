//
//  UILabel+Extension.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public extension UILabel {

    func startBlink() {
        UIView.animate(withDuration: 0.8,
                       delay: 0.0,
                       options: [.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.alpha = 0.3 },
                       completion: nil)
    }

    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }

    static func build(withSize size: CGFloat, alpha: CGFloat? = 1, weight: UIFont.Weight? = .none, color: UIColor? = .appTitle, alignment: NSTextAlignment? = .left, text: String? = nil, italic: Bool = false) -> UILabel {
        let label = UILabel()
        if let alpha = alpha {
            label.alpha = alpha
        }

        if italic {
            label.font = UIFont.italicSystemFont(ofSize: size)
        } else if let weight = weight {
            label.font = UIFont.systemFont(ofSize: size, weight: weight)
        } else {
            label.font = UIFont.systemFont(ofSize: size)
        }

        if let color = color {
            label.textColor = color
        }
        if let alignment = alignment {
            label.textAlignment = alignment
        }
        label.enableAutoLayout()
        label.numberOfLines = 0
        label.text = text
        label.contentMode = .scaleToFill
        return label
    }

    func withSize(_ size: CGFloat) {
        self.font = UIFont.systemFont(ofSize: size)
    }
}
