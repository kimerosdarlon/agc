//
//  IndeterminateProgressBar.swift
//  CAD
//
//  Created by Samir Chaves on 16/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class IndeterminateProgressBar: UIView {
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    let bar: UIView = {
        let view = UIView()
        view.backgroundColor = .appBlue
        return view
    }()

    init() {
        isLoading = false
        super.init(frame: .zero)
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isLoading: Bool {
        didSet {
            layer.removeAllAnimations()
            background.transform = CGAffineTransform.identity.translatedBy(x: -background.frame.width / 2, y: 0)
            bar.transform = CGAffineTransform.identity.scaledBy(x: 0.05, y: 1)

            if isLoading {
                isHidden = false
                let width = self.background.frame.width
                UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse]) {
                    self.bar.transform = CGAffineTransform.identity.scaledBy(x: 0.4, y: 1)
                }
                UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse]) {
                    self.background.transform = CGAffineTransform.identity.translatedBy(x: width / 2, y: 0)
                }
            } else {
                isHidden = true
            }
        }
    }

    override func layoutSubviews() {
        if !isLoading {
            background.transform = CGAffineTransform.identity.translatedBy(x: -background.frame.width / 2, y: 0)
            bar.transform = CGAffineTransform.identity.scaledBy(x: 0.05, y: 1)
        }
    }

    override func didMoveToSuperview() {
        background.addSubview(bar)
        addSubview(background)
        background.enableAutoLayout().height(self).width(self)
        bar.enableAutoLayout().height(background).width(background)
        enableAutoLayout()
    }
}
