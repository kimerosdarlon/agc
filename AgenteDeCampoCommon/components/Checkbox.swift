//
//  Checkbox.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 12/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public class Checkbox: UIButton {

    public weak var delegate: CheckboxDelegate?
    public weak var handlerView: UIView?

    private let checkImage = UIImage(systemName: "checkmark")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    private let dotImage = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)

    public enum CheckboxStyle {
        case squared, rounded
    }

    public init(style: CheckboxStyle = .squared) {
        super.init(frame: .init(x: 0, y: 0, width: 20, height: 20))
        switch style {
        case .rounded:
            self.layer.cornerRadius = 10
            self.setImage(dotImage, for: .normal)
            self.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        case .squared:
            self.layer.cornerRadius = 5
            self.setImage(checkImage, for: .normal)
        }
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.6).cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.alpha = 1
            } else {
                self.alpha = 0.5
            }
        }
    }

    public var isChecked: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2) { [weak self] in
                if self?.isChecked == true {
                    self?.imageView?.layer.transform = CATransform3DIdentity
                    self?.backgroundColor = UIColor.appBlue
                    self?.layer.borderColor = UIColor.appBlue.cgColor
                } else {
                    self?.imageView?.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
                    self?.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.6).cgColor
                    self?.backgroundColor = UIColor.appTitle.withAlphaComponent(0)
                }
            }

            delegate?.didChanged(checkbox: self)
        }
    }

    public override func awakeFromNib() {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        self.handlerView?.isUserInteractionEnabled = true
        self.handlerView?.addGestureRecognizer(viewTap)
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        if !isChecked {
            self.isChecked = false
        }
    }

    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        buttonClicked(sender: self)
    }

    @objc func buttonClicked(sender: UIButton) {
        if sender == self && isEnabled {
            isChecked = !isChecked
        }
    }
}
