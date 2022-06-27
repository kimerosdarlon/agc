//
//  SingleChoiceAnswerView.swift
//  CAD
//
//  Created by Samir Chaves on 29/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class SingleChoiceAnswerView: UIView {
    weak var delegate: QuestionAnswerDelegate?
    private var alternatives: [Alternative]
    private var checkboxes = [Checkbox]()
    private var containers = [UIView]()

    init(toQuestion question: Question) {
        self.alternatives = question.alternatives ?? []
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getCheckboxLabel() -> UILabel {
        let label = UILabel()
        label.alpha = 0.8
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .appTitle
        label.enableAutoLayout()
        return label
    }

    func configure(withDelegate delegate: QuestionAnswerDelegate) {
        enableAutoLayout()
        self.delegate = delegate
        alternatives.enumerated().forEach { (i, alternative) in
            let containerView = UIView(frame: .zero).enableAutoLayout()
            containerView.layer.cornerRadius = 5
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.3).cgColor
            let label = getCheckboxLabel()
            let checkbox = Checkbox(style: .rounded)
            checkbox.handlerView = containerView
            label.text = alternative.text
            label.numberOfLines = 0
            label.contentMode = .scaleToFill
            checkbox.delegate = self
            checkbox.awakeFromNib()
            checkbox.enableAutoLayout()
            checkbox.height(20)
            checkbox.width(20)
            containerView.addSubview(checkbox)
            containerView.addSubview(label)
            self.addSubview(containerView)
            containers.append(containerView)
            checkboxes.append(checkbox)

            if i == 0 {
                containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            } else {
                containerView.topAnchor.constraint(equalTo: containers[i - 1].bottomAnchor, constant: 10).isActive = true
            }

            if i == alternatives.count - 1 {
                bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 5).isActive = true
            }

            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                checkbox.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
                checkbox.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
                label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
                label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 15),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
            ])
        }
    }
}

extension SingleChoiceAnswerView: QuestionAnswer, CheckboxDelegate {

    func shouldShowJustificativeCheckbox() -> Bool {
        true
    }

    func shouldShowJustificativeField() -> Bool {
        false
    }

    func didChanged(checkbox: Checkbox) {
        delegate?.didAnswered(answer: getSelected())

        UIView.animate(withDuration: 0.2) {
            if checkbox.isChecked {
                self.checkboxes.forEach {
                    if $0 != checkbox && $0.isChecked {
                        $0.isChecked = false
                    }
                }
                checkbox.handlerView?.alpha = 1
                checkbox.handlerView?.backgroundColor = UIColor.appBlue.withAlphaComponent(0.5)
            } else {
                checkbox.handlerView?.alpha = 0.6
                checkbox.handlerView?.backgroundColor = .clear
            }
        }
    }

    func getSelected() -> Int {
        let answer: Int? = alternatives.enumerated().filter { (i, _) in
            if i < checkboxes.count {
                let checkbox = checkboxes[i]
                return checkbox.isChecked
            }
            return false
        }.map { $0.element.value }.first
        return answer == nil ? -1 : answer!
    }

    func getAnswer() -> AnswerValue? {
        return AnswerValue.singleChoice(getSelected())
    }

    func didSelectedBlankOption() {
        checkboxes.forEach { checkbox in
            checkbox.isEnabled = false
            checkbox.handlerView?.alpha = 0.4
        }
    }

    func didUnselectedBlankOption() {
        checkboxes.forEach { checkbox in
            checkbox.isEnabled = true
            if checkbox.isChecked {
                checkbox.handlerView?.alpha = 1
            } else {
                checkbox.handlerView?.alpha = 0.6
            }
        }
    }
}
