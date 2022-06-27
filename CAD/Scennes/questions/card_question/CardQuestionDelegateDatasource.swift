//
//  CardQuestionDelegateDatasource.swift
//  CAD
//
//  Created by Ramires Moreira on 25/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

protocol CardQuestionDelegateDatasource: class {

    func goToNextQuestion()
    func backToPreviousQuestion()
    func shouldShowPreviousButton() -> Bool
    func shouldShowFinishButton() -> Bool
    func finishChecklist()
    func leaveChecklist()
}
