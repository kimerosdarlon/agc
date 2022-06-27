//
//  QuestionView.swift
//  CAD
//
//  Created by Samir Chaves on 13/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

protocol QuestionAnswer: UIView {
    func didSelectedBlankOption()
    func didUnselectedBlankOption()
    func shouldShowJustificativeCheckbox() -> Bool
    func shouldShowJustificativeField() -> Bool
    func configure(withDelegate delegate: QuestionAnswerDelegate)
    func getAnswer() -> AnswerValue?
}

protocol QuestionAnswerDelegate: class {
    func didAnswered(answer: Any)
}
