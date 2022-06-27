//
//  MultipleChoiceAnswerView.swift
//  CAD
//
//  Created by Samir Chaves on 13/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class MultipleChoiceAnswerView: UIView {
    weak var delegate: QuestionAnswerDelegate?
    private var alternatives: [Alternative]
    private var checkboxes = [Checkbox]()
    private var labels = [UILabel]()

    init(toQuestion question: Question) {
        self.alternatives = question.alternatives ?? []
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getCheckboxLabel() -> UILabel {
        let label = UILabel()
        label.alpha = 0.6
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .appTitle
        label.enableAutoLayout()
        return label
    }

    func configure(withDelegate delegate: QuestionAnswerDelegate) {
        enableAutoLayout()
        self.delegate = delegate
        alternatives.enumerated().forEach { (i, alternative) in
            let label = getCheckboxLabel()
            let checkbox = Checkbox()
            checkbox.handlerView = label
            label.text = alternative.text
            label.numberOfLines = 0
            label.contentMode = .scaleToFill
            checkbox.delegate = self
            checkbox.awakeFromNib()
            checkbox.enableAutoLayout()
            checkbox.height(20)
            checkbox.width(20)
            self.addSubview(checkbox)
            self.addSubview(label)
            labels.append(label)
            checkboxes.append(checkbox)

            if i == 0 {
                checkbox.topAnchor.constraint(equalTo: topAnchor).isActive = true
            } else {
                checkbox.topAnchor.constraint(equalTo: labels[i - 1].bottomAnchor, constant: 15).isActive = true
            }

            if i == alternatives.count - 1 {
                bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 5).isActive = true
            }

            NSLayoutConstraint.activate([
                checkbox.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.topAnchor.constraint(equalTo: checkbox.topAnchor),
                label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 15),
                label.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }
}

extension MultipleChoiceAnswerView: QuestionAnswer, CheckboxDelegate {

    func shouldShowJustificativeCheckbox() -> Bool {
        true
    }

    func shouldShowJustificativeField() -> Bool {
        false
    }

    func didChanged(checkbox: Checkbox) {
        delegate?.didAnswered(answer: getAnswers())
        UIView.animate(withDuration: 0.2) {
            if checkbox.isChecked {
                checkbox.handlerView?.alpha = 1
            } else {
                checkbox.handlerView?.alpha = 0.6
            }
        }
    }

    func getAnswers() -> [Int] {
        let answers: [Int?] = alternatives.enumerated().map { (i, alternative) in
            if i < checkboxes.count {
                let checkbox = checkboxes[i]
                return checkbox.isChecked ? alternative.value : nil
            }
            return nil
        }
        return answers.compactMap { $0 }
    }

    func getAnswer() -> AnswerValue? {
        return AnswerValue.multipleChoice(getAnswers())
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
