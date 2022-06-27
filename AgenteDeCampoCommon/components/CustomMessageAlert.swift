//
//  CustomMessageAlert.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 05/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public protocol CustomMessageAlertDelegate: AnyObject {
    func didVisibilityChanged(_ isVisible: Bool)
}

public class CustomMessageAlert: UIView {
    private var visible = false
    public weak var delegate: CustomMessageAlertDelegate?

    public init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var warningMessageIcon: UIImageView = {
        let image = UIImage(systemName: "exclamationmark.circle.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let view = UIImageView(image: image)
        view.enableAutoLayout()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private var warningMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTitle
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
        label.textAlignment = .center
        label.enableAutoLayout()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private var warningMessageView: UIView = {
        let view = UIView(frame: .zero)
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.layer.cornerRadius = 10
        effectView.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.addSubview(effectView)
        view.enableAutoLayout()
        view.alpha = 0
        return view
    }()

    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        hide()
    }

    public func configure(withText text: String, inView superview: UIView) {
        warningMessageLabel.text = text
        warningMessageView.addSubview(warningMessageLabel)
        warningMessageView.addSubview(warningMessageIcon)
        superview.addSubview(warningMessageView)
        superview.bringSubviewToFront(warningMessageView)

        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        warningMessageView.isUserInteractionEnabled = true
        warningMessageView.addGestureRecognizer(tabGesture)

        warningMessageView.centerX(view: superview)
        warningMessageView.centerY(view: superview)
        warningMessageView.width(250)
        warningMessageLabel.centerX(view: warningMessageView)
        warningMessageLabel.centerY(view: warningMessageView)
        warningMessageIcon.width(30)
        warningMessageIcon.height(30)
        warningMessageIcon.centerX(view: warningMessageView)
        NSLayoutConstraint.activate([
            warningMessageIcon.bottomAnchor.constraint(equalTo: warningMessageLabel.topAnchor, constant: -20),
            warningMessageLabel.widthAnchor.constraint(equalTo: warningMessageView.widthAnchor, multiplier: 1, constant: -20),

            warningMessageView.topAnchor.constraint(equalTo: warningMessageIcon.topAnchor, constant: -20),
            warningMessageView.bottomAnchor.constraint(equalTo: warningMessageLabel.bottomAnchor, constant: 20)
        ])
    }

    public func show() {
        if !visible {
            self.warningMessageView.transform = CGAffineTransform(translationX: 0, y: -10)
            warningMessageView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.warningMessageView.alpha = 1.0
                self.warningMessageView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            visible = true
            delegate?.didVisibilityChanged(visible)
        }
    }

    public func hide() {
        if visible {
            UIView.animate(withDuration: 0.2, animations: {
                self.warningMessageView.transform = CGAffineTransform(translationX: 0, y: 20)
                self.warningMessageView.alpha = 0.0
            }, completion: { _ in
                self.warningMessageView.isHidden = true
            })
            visible = false
            delegate?.didVisibilityChanged(visible)
        }
    }

    public func toggle() {
        if visible {
            hide()
        } else {
            show()
        }
    }

    public func isVisible() -> Bool { visible }
}
