//
//  QuestionsViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 25/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

public class QuestionsViewController: UIViewController {

    private var questionsComponent: QuestionsComponent?
    private var team: Team!

    @CadServiceInject
    private var cadService: CadService

    private var replyForm: ReplyForm?

    private var questions = [Question]()

    private var currentQuestion: Int = 0 {
        didSet {
            if currentQuestion > questions.count - 1 {
                currentQuestion = questions.count - 1
            }
            questionCounterLabel.text = "QUESTÃO \(currentQuestion + 1)/\(questions.count)"
            questionCounterPB.setProgress(Float(currentQuestion + 1) / Float(questions.count), animated: true)
        }
    }

    public let activityIndicator = UIActivityIndicatorView(style: .large)

    init(withTeam team: Team) {
        super.init(nibName: nil, bundle: nil)
        self.team = team
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let questionCounterLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .appTitle
        return label
    }()

    private let questionCounterPB: UIProgressView = {
        let progress = UIProgressView()
        progress.enableAutoLayout()
        progress.progressTintColor = .appBlue
        progress.backgroundColor = .appBackground
        return progress
    }()

    private func startLoading() {
        garanteeMainThread {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }

    private func stopLoading() {
        garanteeMainThread {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    private func getChecklist() {
        startLoading()
        let safeArea = view.safeAreaLayoutGuide
        cadService.getChecklist { [unowned self] result in
            switch result {
            case .success(let checklist):
                garanteeMainThread {
                    self.questions = checklist.questions
                    self.currentQuestion = 0
                    let component = QuestionsComponent(viewModel: QuestionViewModel(questions: questions))
                    self.questionsComponent = component
                    self.view.addSubview(component)
                    component.delegate = self
                    component.enableAutoLayout()
                    NSLayoutConstraint.activate([
                        safeArea.trailingAnchor.constraint(equalTo: component.trailingAnchor),
                        safeArea.bottomAnchor.constraint(equalTo: component.bottomAnchor),
                        component.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
                        component.topAnchor.constraint(equalTo: self.questionCounterPB.bottomAnchor)
                    ])
                    component.backgroundColor = .appBackground
                }
            case .failure(let error):
                self.handlerRequestError(error)
            }
            stopLoading()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checklist"

        getChecklist()

        view.addSubview(activityIndicator)
        view.addSubview(questionCounterPB)
        view.addSubview(questionCounterLabel)
        view.bringSubviewToFront(questionCounterLabel)
        view.bringSubviewToFront(questionCounterPB)
        questionCounterPB.height(5)

        let safeArea = view.safeAreaLayoutGuide
        activityIndicator.enableAutoLayout()
        activityIndicator.height(100).width(100)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            questionCounterLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            questionCounterLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 5),
            questionCounterPB.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            questionCounterPB.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            questionCounterPB.topAnchor.constraint(equalTo: questionCounterLabel.bottomAnchor, constant: 10)
        ])
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        view.backgroundColor = .appBackground
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        questionsComponent?.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension QuestionsViewController: QuestionsComponentDelegate, EquipmentPickerDelegate {

    func getBadAnswersFeedbackMessage(fromResponsesIndexes indexes: [String]) -> String {
        let lastIndex = indexes.count - 1
        let lastQuestion = "\(indexes[lastIndex])"
        let initialElements = indexes[0 ..< lastIndex]
        var message = "A questão \(lastQuestion) precisa ser respondida ou justificada corretamente."
        if initialElements.count > 0 {
            let questions = "\(Array(initialElements).joined(separator: ", ")) e \(lastQuestion)"
            message = "As questões \(questions) precisam ser respondidas ou justificadas corretamente."
        }

        return message
    }

    private func backToTeamsScreen() {
        cadService.refreshResource { error in
            garanteeMainThread {
                if let error = error as NSError?, self.isUnauthorized(error) {
                    self.gotoLogin(error.domain)
                } else {
                    self.navigationController?.setViewControllers([TeamViewController()], animated: true)
                }
            }
        }
    }

    private func showSuccessModal(completion: @escaping () -> Void) {
        SuccessViewController(feedbackText: "Sua equipe foi ativada com sucesso!", backgroundColor: .appBlue)
            .showModal(self, duration: 1.5, completion: completion)
    }

    private func startService() {
        guard let replyForm = self.replyForm else { return }
        cadService.startService(withEquipments: [], andChecklistReply: replyForm) { result in
            switch result {
            case .success:
                garanteeMainThread {
                    self.showSuccessModal {
                        self.backToTeamsScreen()
                    }
                }
            case .failure(let error as NSError):
                self.showErrorPage(title: "Não foi possível ativar a equipe.", error: error, onRetry: {
                    self.cadService.refreshResource { error in
                        garanteeMainThread {
                            if let error = error as NSError?, self.isUnauthorized(error) {
                                self.gotoLogin(error.domain)
                            } else {
                                if let activeTeamName = self.cadService.getActiveTeam()?.name,
                                   let currentTeamName = self.team?.name,
                                   activeTeamName == currentTeamName {
                                    self.navigationController?.setViewControllers([TeamViewController()], animated: true)
                                } else {
                                    self.startService()
                                }
                            }
                        }
                    }
                })
            }
        }
    }

    func continueToEquipments(responses: [Response]) {
        replyForm = ReplyForm(team: team.id, responses: responses)
        if team.hasVehicles() {
            let equipmentsViewController = EquipmentsKmViewController(toActivateTeam: team.id, withEquipments: team.getVehicles(), andReply: replyForm!)
            self.navigationController?.pushViewController(equipmentsViewController, animated: true)
        } else {
            if team.equipments.isEmpty {
                self.startService()
            } else {
                if team.equipments.isEmpty {
                    self.startService()
                } else {
                    let equipmentPicker = EquipmentPickerViewController(equipments: team.equipments)
                    equipmentPicker.delegate = self
                    present(equipmentPicker, animated: true)
                }
            }
        }
    }

    func didFinishChecklistWithUnacceptableResponses(responsesIndexes: [String]) {
        let alertController = UIAlertController(
            title: "Questões não respondidas",
            message: getBadAnswersFeedbackMessage(fromResponsesIndexes: responsesIndexes),
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

    func didChangeCurrentQuestion(_ page: Int) {
        currentQuestion = page
    }

    func didSkip() {
        startService()
    }

    func didSelect(equipment: Equipment?) {
        startService()
    }
}
