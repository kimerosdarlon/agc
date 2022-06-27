//
//  LegalWarning.swift
//  CAD
//
//  Created by Samir Chaves on 17/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class LegalWarningViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var onAgreed: () -> Void = { }

    fileprivate let agreeButton: AGCRoundedButton = {
        let button = AGCRoundedButton(text: "Entendi, continuar", loadingText: "")
        button.backgroundColor = .appBlue
        button.setTitleColor(.white, for: .disabled)
        button.addTarget(self, action: #selector(agreeTerms), for: UIControl.Event.touchUpInside)
        return button
    }()

    private func setTermsText() {
        termsText.text = """
            Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.

            At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.

            At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
            Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam.

             erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
            Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod.
        """
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .appTitle
        label.text = "Aviso Legal de Responsabilidade"
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .appTitle
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
        label.text = "Ao responder o questionário a seguir, você aceita os seguintes termos:"
        return label
    }()

    private let termsText: UITextView = {
        let view = UITextView()
        view.enableAutoLayout()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        view.layer.cornerRadius = 10
        view.alpha = 0.7
        view.isEditable = false
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 15),

            descriptionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),

            termsText.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            termsText.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.9),
            termsText.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
            termsText.bottomAnchor.constraint(equalTo: agreeButton.topAnchor, constant: -15),

            agreeButton.widthAnchor.constraint(equalToConstant: 231),
            agreeButton.heightAnchor.constraint(equalToConstant: 42),
            agreeButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            agreeButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15)
        ])
    }

    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(termsText)
        agreeButton.isEnabled = false
        agreeButton.enableAutoLayout()
        view.addSubview(agreeButton)
    }

    @IBAction private func dismissModal() {
        garanteeMainThread {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func agreeTerms() {
        self.dismiss(animated: true) {
            self.onAgreed()
        }
    }

    func presentModalIfNotAgreed(in parentView: UIViewController) {
        garanteeMainThread {
            if !UserService.shared.getTermsStatus()!.agreed {
                parentView.present(self, animated: true, completion: nil)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConstraints()
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTermsText()
        termsText.delegate = self
        self.isModalInPresentation = true
        view.backgroundColor = .appBackground
        addSubViews()
    }
}

extension LegalWarningViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height && !self.agreeButton.isEnabled {
            self.agreeButton.isEnabled = true
        }
    }
}
