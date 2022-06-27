//
//  BinaryAnswerView.swift
//  CAD
//
//  Created by Samir Chaves on 13/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class BinaryAnswerView: UIView {

    weak var delegate: QuestionAnswerDelegate?

    private var answer: Bool? {
        didSet {
            if answer == true {
                delegate?.didAnswered(answer: answer!)
                yesBtn.layer.borderColor = UIColor.appBlue.cgColor
                yesBtn.backgroundColor = UIColor.appBlue
                yesBtn.titleLabel?.textColor = .white
                noBtn.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.6).cgColor
                noBtn.titleLabel?.textColor = UIColor.appTitle.withAlphaComponent(0.6)
                noBtn.backgroundColor = UIColor.appTitle.withAlphaComponent(0)
            } else if answer == false {
                delegate?.didAnswered(answer: answer!)
                noBtn.layer.borderColor = UIColor.appBlue.cgColor
                noBtn.backgroundColor = UIColor.appBlue
                noBtn.titleLabel?.textColor = .white
                yesBtn.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.6).cgColor
                yesBtn.titleLabel?.textColor = UIColor.appTitle.withAlphaComponent(0.6)
                yesBtn.backgroundColor = UIColor.appTitle.withAlphaComponent(0)
            }
        }
    }

    private var yesBtn: UIButton!
    private var noBtn: UIButton!

    init() {
        super.init(frame: .zero)
        yesBtn = getButton(withText: "VERDADEIRO")
        noBtn = getButton(withText: "FALSO")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getButton(withText text: String) -> UIButton {
        let btn = UIButton()
        btn.layer.cornerRadius = 5
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.6).cgColor
        btn.titleLabel?.textColor = UIColor.appTitle.withAlphaComponent(0.6)
        btn.setTitle(text, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.enableAutoLayout()
        return btn
    }

    func configure(withDelegate delegate: QuestionAnswerDelegate) {
        addSubview(yesBtn)
        addSubview(noBtn)

        self.delegate = delegate

        yesBtn.addAction {
            self.answer = true
        }

        noBtn.addAction {
            self.answer = false
        }

        enableAutoLayout()

        yesBtn.height(50)
        noBtn.height(50)

        NSLayoutConstraint.activate([
            yesBtn.topAnchor.constraint(equalTo: topAnchor),
            yesBtn.trailingAnchor.constraint(equalTo: trailingAnchor),
            yesBtn.leadingAnchor.constraint(equalTo: leadingAnchor),

            noBtn.topAnchor.constraint(equalTo: yesBtn.bottomAnchor, constant: 10),
            noBtn.trailingAnchor.constraint(equalTo: trailingAnchor),
            noBtn.leadingAnchor.constraint(equalTo: leadingAnchor),

            bottomAnchor.constraint(equalTo: noBtn.bottomAnchor)
        ])
    }
}

extension BinaryAnswerView: QuestionAnswer {
    func shouldShowJustificativeCheckbox() -> Bool {
        false
    }

    func shouldShowJustificativeField() -> Bool {
        answer == false
    }

    func didSelectedBlankOption() { }

    func didUnselectedBlankOption() { }

    func getAnswer() -> AnswerValue? { answer.map { AnswerValue.binary($0) } }
}
