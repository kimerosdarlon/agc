//
//  TermsAgreementController.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 30/09/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import SwiftyBeaver
import UIKit

class TermsAgreementController: UIViewController {

    private let formatter = DateFormatter()
    private let confidentialityService = ConfidentialityService()

    init() {
        super.init(nibName: nil, bundle: nil)
        formatter.dateFormat = "dd 'de' MMMM 'de' yyyy 'às' HH:mm"
        formatter.locale = Locale(identifier: "pt_BR")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let agreeButton: AGCRoundedButton = {
        let button = AGCRoundedButton(text: "Li e concordo", loadingText: "")
        button.backgroundColor = .appBlue
        button.setTitleColor(.white, for: .disabled)
        button.addTarget(self, action: #selector(TermsAgreementController.agreeTerms), for: UIControl.Event.touchUpInside)
        return button
    }()

    private let logoImg: UIImageView! = {
        let img = UIImageView(image: UIImage(named: "logo_default"))
        img.enableAutoLayout()
        img.width(50).height(50)
        return img
    }()

    private func setTermsText(at agreementDate: Date, in organization: Organization?) {
        let formattedDate = formatter.string(from: agreementDate)
        let footnote = organization != nil ? "\n\(organization!.name)\n\n\(organization!.city) - \(organization!.state), \(formattedDate)" : ""

        let attributedFootnote = NSMutableAttributedString(
            string: footnote,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.textField,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
            ]
        )

        if let path = Bundle.main.path(forResource: "TermsContent", ofType: "html") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let rawText = String(data: data, encoding: String.Encoding.utf8)
                let content = NSMutableAttributedString()
                let attributedText = rawText?.htmlToAttributedString
                if attributedText != nil {
                    garanteeMainThread {
                        attributedText!.addAttributes(
                            [NSAttributedString.Key.foregroundColor: UIColor.textField],
                            range: NSRange(location: 0, length: attributedText!.string.count - 1)
                        )
                        content.append(attributedText!)
                        content.append(attributedFootnote)
                        self.termsText.attributedText = content
                    }
                }
            } catch {
                termsText.text = "Não foi possível carregar os termos, por favor, tente novamente."
            }
        }
    }

    private let termsText: UITextView = {
        let view = UITextView()
        view.enableAutoLayout()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        view.layer.cornerRadius = 10
        view.isEditable = false
        return view
    }()

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            logoImg.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 15.0),
            logoImg.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            termsText.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            termsText.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.9),
            termsText.topAnchor.constraint(equalTo: logoImg.bottomAnchor, constant: 15)
        ])

        let termsStatus = UserService.shared.getTermsStatus()
        if termsStatus == nil || !termsStatus!.agreed {
            NSLayoutConstraint.activate([
                agreeButton.widthAnchor.constraint(equalToConstant: 231),
                agreeButton.heightAnchor.constraint(equalToConstant: 42),
                agreeButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                agreeButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
                termsText.bottomAnchor.constraint(equalTo: agreeButton.topAnchor, constant: -15)
            ])
        } else {
            termsText.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15).isActive = true
        }
    }

    private func addSubViews() {
        view.addSubview(self.logoImg)
        view.addSubview(self.termsText)
        self.agreeButton.isEnabled = false
        self.agreeButton.enableAutoLayout()
        view.addSubview(self.agreeButton)
    }

    @IBAction private func dismissModal() {
        garanteeMainThread {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func agreeTerms() {
        agreeButton.startLoad()
        UserService.shared.agreeTerms {
            let termsStatus = UserService.shared.getTermsStatus()
            if termsStatus == nil || !termsStatus!.agreed {
                self.agreeButton.stopLoad()
                self.dismissModal()
            } else {
                self.agreeButton.stopLoad()
            }
        }
    }

    func presentModalIfNotAgreed(in parentView: UIViewController) {
        checkAgreement {
            garanteeMainThread {
                if !UserService.shared.getTermsStatus()!.agreed {
                    parentView.present(self, animated: true, completion: nil)
                }
            }
        }
    }

    func checkAgreement(completion: (() -> Void)? = nil) {
        let formatter = DateFormatter()
        let isBeingPresented = self.isBeingPresented
        UserService.shared.checkTermsAgreement {
            let status = UserService.shared.getTermsStatus()
            let userData = UserService.shared.getCurrentUser()
            if status?.agreed == false {
                self.setTermsText(at: Date(), in: userData?.organization)
            } else {
                guard let agreement = status?.agreement else { return }
                let agreementDate = formatter.date(from: agreement.dateTime)
                self.setTermsText(at: agreementDate ?? Date(), in: status?.agreement?.organization)
                if isBeingPresented {
                    self.dismissModal()
                }
            }

            if completion != nil {
                completion!()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAgreement()
        setupConstraints()
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        view.backgroundColor = .appBackground
        addSubViews()
        termsText.delegate = self
    }
}

extension TermsAgreementController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height && !self.agreeButton.isEnabled {
            self.agreeButton.isEnabled = true
        }
    }
}
