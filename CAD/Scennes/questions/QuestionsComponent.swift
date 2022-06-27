//
//  CardComponent.swift
//  CAD
//
//  Created by Ramires Moreira on 25/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class QuestionsComponent: UIView, CardQuestionDelegateDatasource {

    private var responses = [Response]()

    weak var delegate: QuestionsComponentDelegate?
    private var currentPage: Int = 0 {
        didSet {
            delegate?.didChangeCurrentQuestion(currentPage)
        }
    }
    private var cards = [CardQuestionView]()
    private var displacedCards = [CardQuestionView]()

    private let viewModel: QuestionViewModel

    init(viewModel: QuestionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        for index in 0..<viewModel.totalOfQuestions {
            self.cards.append(makeCardForQuestion(questionModel: viewModel.cardQuestionViewModel(at: index)))
        }

        let finishCard = CardQuestionView().enableAutoLayout()
        insertSubview(finishCard, at: 0)
        NSLayoutConstraint.activate([
            finishCard.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
            finishCard.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            finishCard.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        finishCard.delegateDataSource = self
        self.cards.append(finishCard)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeCardForQuestion(questionModel: CardQuestionViewModel) -> CardQuestionView {
        let card = CardQuestionView(viewModel: questionModel).enableAutoLayout()
        insertSubview(card, at: 0)
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
            card.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            card.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        card.delegateDataSource = self
        return card
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
        subviews.forEach({$0.overrideUserInterfaceStyle = UserStylePreferences.theme.style })
        makeVisible()
    }

    private func makeVisible() {
        for card in cards.reversed() {
            let index = cards.firstIndex(of: card)!
            card.frame.origin.y = topSpace(forIndex: index)
            card.layoutSubviews()
        }
    }

    private func topSpace(forIndex index: Int) -> CGFloat {
        let gap = min(32, index * 16)
        return CGFloat(gap + 50)
    }

    func goToNextQuestion() {
        if cards.isEmpty { return }
        let currentView = cards.removeFirst()
        displacedCards.append(currentView)
        currentPage = displacedCards.count
        UIView.animate(withDuration: 0.2) {
            let yTranslated = (currentView.frame.maxY + 100) * -0.1
            currentView.transform = CGAffineTransform(translationX: 0, y: yTranslated)
            currentView.alpha = 0
            self.makeVisible()
        }
    }

    func backToPreviousQuestion() {
        if displacedCards.isEmpty { return }
        let currentView = displacedCards.removeLast()
        currentPage = displacedCards.count
        cards.insert(currentView, at: 0)
        UIView.animate(withDuration: 0.2) {
            let yTranslated = (currentView.frame.maxY - 100) * -0.1
            currentView.transform = CGAffineTransform(translationX: 0, y: yTranslated)
            currentView.alpha = 1
            self.makeVisible()
        }
    }

    func shouldShowPreviousButton() -> Bool {
        return !displacedCards.isEmpty
    }

    func shouldShowFinishButton() -> Bool {
        // Has left only last question card and the finish card.
        return cards.count == 2
    }

    func getUnacceptableResponsesIndexes(_ responses: [Response]) -> [String] {
        responses.enumerated().map { (i, response) in
            response.isAcceptable() ? -1 : i + 1
        }.filter { $0 > 0 }.map { String($0) }
    }

    func finishChecklist() {
        var allCards = displacedCards
        allCards.append(contentsOf: cards)
        let responses = allCards[0 ..< allCards.endIndex - 1].map { $0.getResponse() } // ignore finish card
        let unacceptableResponses = getUnacceptableResponsesIndexes(responses)

        if unacceptableResponses.isEmpty {
            self.responses = responses
            goToNextQuestion()
//            cadService.replyChecklist(reply: replyForm) { result in
//                switch result {
//                case .success:
//                    self.cadService.refreshResource {
//                        self.navigationController?.setViewControllers([TeamViewController()], animated: true)
//                    }
//                case .failure(let error):
//                    print(error)
//                }
//            }
        } else {
            delegate?.didFinishChecklistWithUnacceptableResponses(responsesIndexes: unacceptableResponses)
        }
    }

    func leaveChecklist() {
        delegate?.continueToEquipments(responses: responses)
    }
}
