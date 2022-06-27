//
//  QuestionsComponentDelegate.swift
//  CAD
//
//  Created by Samir Chaves on 16/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation

protocol QuestionsComponentDelegate: class {
    func didChangeCurrentQuestion(_ page: Int)
    func didFinishChecklistWithUnacceptableResponses(responsesIndexes: [String])
    func continueToEquipments(responses: [Response])
}
