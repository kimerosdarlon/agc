//
//  UITextField+Extension.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 23/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public extension UITextField {

    func addRightIcon(_ image: UIImage?, frame: CGRect) {
        let icon = UIImageView(image: image)
        let container = UIView(frame: .init(x: 0, y: 0, width: 40, height: 30))
        container.alpha = 0.8
        icon.frame = frame
        container.addSubview(icon)
        rightView = container
        rightViewMode = .always
        icon.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickOnRightIcon))
        icon.addGestureRecognizer(tap)
    }

    func addChevron() {
        let icon = UIImage(systemName: "chevron.down")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        addRightIcon(icon, frame: .init(x: 0, y: 10, width: 20, height: 10))
    }

    func addSearchIcon() {
        let icon = UIImage(systemName: "magnifyingglass")?.withTintColor(UIColor.appTitle.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        addRightIcon(icon, frame: .init(x: 5, y: 5, width: 20, height: 19))
    }

    func addClearButton() -> UIView {
        let closeBtn = UIImageView(image: UIImage(systemName: "xmark.circle.fill")?.withTintColor(UIColor.appTitle.withAlphaComponent(0.5), renderingMode: .alwaysOriginal))
        let container = UIView(frame: .init(x: 0, y: 0, width: 30, height: 30))
        closeBtn.frame = .init(x: 7.5, y: 7.5, width: 15, height: 15)
        container.addSubview(closeBtn)
        rightView = container
        rightViewMode = .whileEditing
        return container
    }

    func addLeftIcon(iconName: String, color: UIColor, size: CGSize, frame: CGRect = .init(x: 0, y: 0, width: 30, height: 30), position: CGPoint = .init(x: 7.5, y: 7.5)) {
        let iconImageView = UIImageView(image: UIImage(systemName: iconName)?.withTintColor(color, renderingMode: .alwaysOriginal))
        let container = UIView(frame: frame)
        iconImageView.frame = .init(x: position.x, y: position.y, width: size.width, height: size.height)
        container.addSubview(iconImageView)
        leftView = container
        leftViewMode = .always
    }

    func buildLeftButton(iconName: String, color: UIColor, size: CGFloat? = nil, containerFrame: CGRect? = nil, position: CGPoint = .init(x: 5, y: 5)) -> UIButton {
        let image = UIImage(systemName: iconName)?.withTintColor(color, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .custom)
        let fieldHeight = containerFrame?.height ?? self.bounds.height
        var container: UIView!
        if let size = size {
            btn.frame = .init(x: position.x, y: position.y, width: size - 10, height: size - 10)
            if let containerFrame = containerFrame {
                container = UIView(frame: containerFrame)
            } else {
                container = UIView(frame: .init(x: 0, y: 0, width: size, height: size))
            }
        } else {
            btn.frame = .init(x: position.x, y: position.y, width: fieldHeight - 10, height: fieldHeight - 10)
            if let containerFrame = containerFrame {
                container = UIView(frame: containerFrame)
            } else {
                container = UIView(frame: .init(x: 0, y: 0, width: fieldHeight, height: fieldHeight))
            }
        }
        btn.layer.cornerRadius = btn.bounds.width * 0.5
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(didTapOnLeftButton(_:)), for: .allEvents)
        container.addSubview(btn)
        leftView = container
        leftViewMode = .always
        return btn
    }

    @objc
    private func didTapOnLeftButton(_ sender: UIButton) {
        if sender.isSelected {
            sender.alpha = 0.6
        } else {
            sender.alpha = 1
        }
    }

    @objc
    private func didClickOnRightIcon() {
        becomeFirstResponder()
    }

    var notNullText: String {
        return text ?? ""
    }

    var isNotEmpty: Bool {
        return !notNullText.isEmpty
    }
}
