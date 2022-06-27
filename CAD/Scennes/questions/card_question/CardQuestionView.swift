//
//  CardQuestionView.swift
//  CAD
//
//  Created by Ramires Moreira on 25/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

private func getRoudedButton(text: String, width: CGFloat, height: CGFloat, iconName: String? = nil) -> UIButton {
    var btn = AGCRoundedButton(text: text)
    if let iconName = iconName {
        btn = btn.setRightIcon(UIImage(systemName: iconName)!.withTintColor(.white, renderingMode: .alwaysOriginal))
    }
    return btn.enableAutoLayout().width(width).height(height)
}

class CardQuestionView: UIView {

    public var viewModel: CardQuestionViewModel!
    weak var delegateDataSource: CardQuestionDelegateDatasource?

    private let nextButton = getRoudedButton(text: "Próxima", width: 100, height: 40, iconName: "arrow.right")
    private let finishButton = getRoudedButton(text: "Finalizar", width: 110, height: 40, iconName: "arrow.right")
    private let continueButton = getRoudedButton(text: "Continuar", width: 110, height: 40, iconName: "arrow.right")
    private let backButton = getRoudedButton(text: "Voltar", width: 100, height: 40)

    private var justificativeField: UITextView!
    private var justificativeFieldHeight: NSLayoutConstraint!

    private var answerView: QuestionAnswer!

    private var answerContainer: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.enableAutoLayout()
        return scrollView
    }()

    init(viewModel: CardQuestionViewModel) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        self.justificativeField = getTextArea()
        self.justificativeField.delegate = self

        switch viewModel.question.type {
        case .textual:
            answerView = TextualAnswerView()
        case .binary:
            answerView = BinaryAnswerView()
        case .multipleChoice:
            answerView = MultipleChoiceAnswerView(toQuestion: viewModel.question)
        case .singleChoice:
            answerView = SingleChoiceAnswerView(toQuestion: viewModel.question)
        case .quantitative:
            answerView = QuantitativeAnswerView()
        }

        configure()
    }

    init() {
        super.init(frame: .zero)
        configure()
    }

    private let indicativeLabel: UILabel = UILabel.build(withSize: 16, alpha: 0.7)

    private let feedbackLabel: UILabel = UILabel.build(withSize: 15)

    private let complementLabel: UILabel = UILabel.build(withSize: 15)

    private let emojiImage: UIImageView! = {
        let image = UIImage(systemName: "smiley")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let imgView = UIImageView(image: image)
        imgView.enableAutoLayout()
        imgView.width(50).height(50)
        return imgView
    }()

    private let checkboxLabel: UILabel = UILabel.build(withSize: 16, alpha: 0.6)

    private let title: UILabel = UILabel.build(withSize: 21, alpha: 1, weight: .bold)

    func getTextArea() -> UITextView {
        let textField = UITextView()
        textField.backgroundColor = UIColor.textField.withAlphaComponent(0.1)
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        textField.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        textField.layer.cornerRadius = 5
        textField.enableAutoLayout()
        textField.keyboardType = .alphabet
        textField.autocorrectionType = .no
        textField.font = UIFont.systemFont(ofSize: 15)
        return textField
    }

    private let checkbox = Checkbox()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getIndicativeText() -> String {
        switch viewModel.question.type {
        case .textual:
            checkboxLabel.text = "Não responder"
            return "Descreva sua resposta"
        case .binary:
            return "Selecione uma resposta"
        case .multipleChoice:
            checkboxLabel.text = "Nenhuma das anteriores"
            return "Selecione uma resposta"
        case .singleChoice:
            checkboxLabel.text = "Nenhuma das anteriores"
            return "Selecione uma resposta"
        case .quantitative:
            checkboxLabel.text = "Não responder"
            return "Descreva sua resposta"
        }
    }

    func showJustificativeField() {
        self.justificativeFieldHeight?.constant = 150
        self.justificativeField.becomeFirstResponder()
        self.answerView.didSelectedBlankOption()
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            self.answerContainer.layoutIfNeeded()
            self.checkboxLabel.alpha = 1
        }
    }

    func hideJustificativeField() {
        self.justificativeFieldHeight?.constant = 0
        self.justificativeField.resignFirstResponder()
        self.answerView.didUnselectedBlankOption()
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            self.answerContainer.layoutIfNeeded()
            if self.answerView.shouldShowJustificativeCheckbox() {
                self.checkboxLabel.alpha = 0.6
            } else {
                self.checkboxLabel.alpha = 0
            }
        }
    }

    private func configure() {
        backgroundColor = .appBackgroundCell
        nextButton.addTarget(self, action: #selector(goToNext), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishChecklist), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(leaveChecklist), for: .touchUpInside)
        backButton.setTitleColor(.appTitle, for: .normal)

        if viewModel != nil {
            indicativeLabel.text = getIndicativeText()
            title.text = viewModel.question.text

            checkbox.delegate = self
            checkbox.handlerView = checkboxLabel
            checkbox.awakeFromNib()
            checkbox.enableAutoLayout()

            if !answerView.shouldShowJustificativeCheckbox() {
                checkbox.isHidden = true
                checkboxLabel.text = "Justifique sua resposta:"
                checkboxLabel.alpha = 0
            }
            backButton.backgroundColor = .clear
        } else {
            indicativeLabel.text = "Fim"
            title.text = "Questionário finalizado com sucesso!"
            feedbackLabel.text = "Tome as precauções necessárias no patrulhamento e no atendimento de ocorrência."
            complementLabel.text = "Tudo Ok, tenha um excelente serviço!"
        }

        addSubViews()

        setupConstraints()

        layer.cornerRadius = 8
        layer.shadowColor = UIColor.appBackground.cgColor
        layer.shadowOffset = .init(width: 0, height: 1)
        layer.shadowRadius = 3
        layer.shadowOpacity = 1
        layer.borderColor = UIColor.appBackground.cgColor
        layer.borderWidth = 1
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    @objc private func finishChecklist() {
        delegateDataSource?.finishChecklist()
    }

    @objc private func leaveChecklist() {
        delegateDataSource?.leaveChecklist()
    }

    private func addSubViews() {
        addSubview(indicativeLabel)
        nextButton.isEnabled = false
        finishButton.isEnabled = false

        if viewModel != nil {
            answerContainer.addSubview(title)
            answerContainer.addSubview(answerView)
            answerContainer.addSubview(checkbox)
            answerContainer.addSubview(checkboxLabel)
            answerContainer.addSubview(justificativeField)
            addSubview(answerContainer)
            addSubview(nextButton)
            addSubview(backButton)
            addSubview(finishButton)
        } else {
            addSubview(title)
            addSubview(feedbackLabel)
            addSubview(continueButton)
            addSubview(emojiImage)
            addSubview(complementLabel)
        }
    }

    private func setupConstraints() {
        let padding: CGFloat = 2

        NSLayoutConstraint.activate([
            indicativeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            indicativeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15)
        ])

        if viewModel == nil {
            NSLayoutConstraint.activate([
                title.topAnchor.constraint(equalTo: indicativeLabel.bottomAnchor, constant: 15),
                title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

                feedbackLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 15),
                feedbackLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                feedbackLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

                continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
                continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
            ])

            if let emojiImage = emojiImage {
                NSLayoutConstraint.activate([
                    emojiImage.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 15),
                    emojiImage.leadingAnchor.constraint(equalTo: title.leadingAnchor),

                    complementLabel.centerYAnchor.constraint(equalTo: emojiImage.centerYAnchor),
                    complementLabel.leadingAnchor.constraint(equalTo: emojiImage.trailingAnchor, constant: 15),
                    complementLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
                ])
            }
        } else {
            checkbox.height(20).width(20)

            justificativeFieldHeight = justificativeField.heightAnchor.constraint(equalToConstant: 0)
            justificativeFieldHeight.isActive = true

            answerView.configure(withDelegate: self)

            answerContainer.width(self)

            var checkboxMargin: CGFloat = 0
            if !answerView.shouldShowJustificativeCheckbox() {
                checkboxMargin = -35
            }

            checkbox.leadingAnchor.constraint(equalTo: answerView.leadingAnchor, constant: checkboxMargin).isActive = true

            NSLayoutConstraint.activate([
                title.topAnchor.constraint(equalTo: answerContainer.topAnchor, constant: 15),
                title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

                answerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                answerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
                answerView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 15),

                checkbox.topAnchor.constraint(equalTo: answerView.bottomAnchor, constant: 15),

                justificativeField.leadingAnchor.constraint(equalTo: checkboxLabel.leadingAnchor),
                justificativeField.trailingAnchor.constraint(equalTo: answerView.trailingAnchor),
                justificativeField.topAnchor.constraint(equalTo: checkbox.bottomAnchor, constant: 15),

                answerContainer.topAnchor.constraint(equalTo: indicativeLabel.bottomAnchor, constant: 15),
                answerContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                answerContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                answerContainer.bottomAnchor.constraint(equalTo: justificativeField.bottomAnchor, constant: 15),

                checkboxLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 15),
                checkboxLabel.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor),
                trailingAnchor.constraint(equalToSystemSpacingAfter: nextButton.trailingAnchor, multiplier: padding),

                nextButton.topAnchor.constraint(equalToSystemSpacingBelow: answerContainer.bottomAnchor, multiplier: padding),
                bottomAnchor.constraint(equalToSystemSpacingBelow: nextButton.bottomAnchor, multiplier: padding),

                finishButton.topAnchor.constraint(equalToSystemSpacingBelow: answerContainer.bottomAnchor, multiplier: padding),
                finishButton.trailingAnchor.constraint(equalTo: nextButton.trailingAnchor),

                backButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: padding),
                backButton.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor)
            ])
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backButton.isHidden = !(delegateDataSource?.shouldShowPreviousButton() ?? false)
        if delegateDataSource?.shouldShowFinishButton() ?? false {
            nextButton.isHidden = true
            finishButton.isHidden = false
        } else {
            finishButton.isHidden = true
            nextButton.isHidden = false
        }
    }

    @objc
    func goToNext() {
        self.delegateDataSource?.goToNextQuestion()
    }

    @objc
    func back() {
        self.delegateDataSource?.backToPreviousQuestion()
    }

    func getResponse() -> Response {
        var justificative: String?
        var answer = answerView.getAnswer()
        if checkbox.isChecked || (!answerView.shouldShowJustificativeCheckbox()) && answerView.shouldShowJustificativeField() {
            justificative = justificativeField.text
            answer = nil
        }

        return Response(question: viewModel.question.id, answer: answer, justificative: justificative)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.appBackground.cgColor
        layer.shadowColor = UIColor.appBackground.cgColor
    }
}

extension CardQuestionView: CheckboxDelegate, QuestionAnswerDelegate {
    func toggleEnability() {
        let response = getResponse()
        if response.isAcceptable() {
            nextButton.isEnabled = true
            finishButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
            finishButton.isEnabled = false
        }
    }

    func didChanged(checkbox: Checkbox) {
        if answerView.shouldShowJustificativeCheckbox() {
            if checkbox.isChecked {
                showJustificativeField()
            } else {
                hideJustificativeField()
            }
        }

        toggleEnability()
    }

    func didAnswered(answer: Any) {
        if !answerView.shouldShowJustificativeCheckbox() && answerView.shouldShowJustificativeField() {
            showJustificativeField()
        } else {
            hideJustificativeField()
        }

        toggleEnability()
    }
}

extension CardQuestionView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        toggleEnability()
    }
}
