//
//  QuestionViewModel.swift
//  CAD
//
//  Created by Ramires Moreira on 25/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

class QuestionViewModel {

    private let questions: [Question]

    init(questions: [Question]) {
        self.questions = questions
    }

    init(checklist: Checklist) {
        self.questions = checklist.questions
    }

    var totalOfQuestions: Int {
        self.questions.count
    }

    func cardQuestionViewModel(at position: Int) -> CardQuestionViewModel {
        CardQuestionViewModel(question: questions[position])
    }
}
