//
//  Toast.swift
//  CAD
//
//  Created by Samir Chaves on 18/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

enum ToastStyle {
    case `default`, thin
}

public class Toast: UIViewController {
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    
    private let blurView: UIView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }()

    private lazy var iconImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal) )
        view.enableAutoLayout().height(22).width(22)
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let titleLabel = UILabel.build(withSize: 13, weight: .bold, color: .appTitle)
    private let messageLabel = UILabel.build(withSize: 15, color: .appTitle)

    private let style: ToastStyle

    private init(title: String?, message: String, style: ToastStyle = .default) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        titleLabel.text = title
        messageLabel.text = message

        transitionDelegate = ToastPresentationManager(width: message.width(withConstrainedHeight: 40, font: .robotoBold))
        transitioningDelegate = transitionDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func present(in viewController: UIViewController, title: String? = nil, message: String, duration: TimeInterval = 3) {
        let alert = Toast(title: title, message: message)
        alert.modalPresentationStyle = .custom
        viewController.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alert.dismiss(animated: true)
        }
    }

    public static func presentThin(in viewController: UIViewController, message: String, duration: TimeInterval = 3) {
        let alert = Toast(title: nil, message: message, style: .thin)
        alert.modalPresentationStyle = .custom
        viewController.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(blurView)
        if style == .thin {
            messageLabel.font = .systemFont(ofSize: 13)
            messageLabel.textAlignment = .center
            view.layer.cornerRadius = 35
        } else {
            view.addSubview(iconImage)
            view.addSubview(titleLabel)
        }
        view.addSubview(messageLabel)
        view.enableAutoLayout()
        view.isUserInteractionEnabled = false

        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true

        setupLayout()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    private func setupLayout() {
        if titleLabel.text != nil {
            NSLayoutConstraint.activate([
                iconImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                iconImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
                titleLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 15),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
                messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

                view.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -15),
                view.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 15)
            ])
        } else {
            if style == .thin {
                NSLayoutConstraint.activate([
                    messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                    messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

                    view.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10),
                    view.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10)
                ])
            } else {
                NSLayoutConstraint.activate([
                    iconImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                    iconImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                    messageLabel.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
                    messageLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 15),
                    messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

                    view.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -15),
                    view.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 15)
                ])
            }
        }
    }
}
