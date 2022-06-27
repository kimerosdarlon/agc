//
//  DriverStatusBadge.swift
//  Driver
//
//  Created by Samir Chaves on 28/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class DriverStatusBadge: PaddingLabel {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init() {
        self.init(withInsets: 4.0, 4.0, 10.0, 10.0)
    }

    func setStatus(_ status: String, withFontSize: CGFloat = 13.0) {
        switch status {
        case "EM DIA":
            self.backgroundColor = .systemGreen
        case "SUSPENSA":
            self.backgroundColor = .appRedAlert
        case "VENCIDA":
            self.backgroundColor = .appYellow
        default:
            self.backgroundColor = .appBlue
        }
        self.attributedText = NSAttributedString(string: status, attributes: [.font: UIFont.boldSystemFont(ofSize: withFontSize)])
    }

    required init(withInsets top: CGFloat, _ bottom: CGFloat, _ left: CGFloat, _ right: CGFloat) {
        super.init(withInsets: top, bottom, left, right)
        self.enableAutoLayout()
        self.textColor = .white
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
    }
}
