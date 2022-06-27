//
//  FormViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 19/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public class FormViewController<BindableModel: FormViewControllerDataSource>: CustomViewController {

    public weak var formDataSource: BindableModel?
    public weak var formDelegate: FormViewControllerDelegate?
    private var offset: CGFloat {
        return formConfig.offset
    }
    private var height: NSLayoutConstraint!
    private let heightOverflow: CGFloat = 100
    private var viewHeight: CGFloat = 0

    private var textFields = [CustomTextFieldFormBindable<BindableModel.Model.Entity>]()
    public var formConfig = FormConstraintsConfig(left: 1, top: 6, right: 1, bottom: 1)

    private var leftButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .appBackgroundCell
        button.titleLabel?.font = UIFont.robotoRegular.withSize(16)
        button.setTitleColor(.appCellLabel, for: .normal)
        return button
    }()

    private var righthButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .appBlue
        button.titleLabel?.font = UIFont.robotoRegular.withSize(16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    private var buttonGroup: UIStackView = {
        let group = UIStackView()
        group.spacing = 0
        group.axis = .horizontal
        group.distribution = .fillEqually
        group.enableAutoLayout()
        return group
    }()

    private var formView: UIStackView = {
        let formView = UIStackView()
        formView.axis = .vertical
        formView.distribution = .fill
        formView.spacing = 12
        formView.enableAutoLayout()
        return formView
    }()

    private var contentView: UIView = {
        let view = UIView()
        view.enableAutoLayout()
        view.backgroundColor = .appBackground
        return view
    }()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.enableAutoLayout()
        view.showsVerticalScrollIndicator = false
        return view
    }()

    private let disposeBag = DisposeBag()
    private var form: BehaviorRelay<BindableModel.Model>?

    public init(dataSource: BindableModel) {
        super.init(nibName: nil, bundle: nil)
        self.formDataSource = dataSource
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func bindUI() {
        guard let dataSource = formDataSource else { return }
        form = dataSource.didReturnBehaviorRelay()
        for textField in textFields where textField.path != nil {
            bind(textField: textField, path: textField.path! )
            for child in textField.children {
                bind(textField: child, path: child.path!)
            }
        }
        leftButton.addTarget(self, action: #selector(didClickOnLeftButton), for: .touchUpInside)
        righthButton.addTarget(self, action: #selector(didClickOnRightButton), for: .touchUpInside)

        leftButton.addTarget(self, action: #selector(didClick(_:_:)), for: UIControl.Event.touchDown)
        righthButton.addTarget(self, action: #selector(didClick(_:_:)), for: UIControl.Event.touchDown)

    }

    public func bind(textField: CustomTextFieldFormBindable<BindableModel.Model.Entity>, path: ReferenceWritableKeyPath<BindableModel.Model.Entity, String?> ) {
        guard let form = form else {return}
        Observable.combineLatest(form.asObservable(), textField.textField.rx.text, resultSelector: { form, value in
            form.set(value: value, path: path)
            self.clearAllExcepted(textField: textField)
        }).subscribe().disposed(by: disposeBag)
    }

    private func addTextFields() {
        guard let dataSorce = formDataSource else { return }
        for position in 0..<dataSorce.numberOfTextFields() {
            let textField = dataSorce.textFieldForm(for: position)
            textFields.append(textField)
            formView.addArrangedSubview(textField)
        }
        updateButtonsState()
    }

    public func clearAllExcepted(textField: CustomTextFieldFormBindable<BindableModel.Model.Entity>) {
        if textField.textField.text!.isEmpty {
            updateButtonsState()
            return
        }
        guard let dataSource = formDataSource else { return }
        if dataSource.isUniqueParameter(textField: textField) {
            textFields.filter({$0.textField != textField.textField})
                .forEach({$0.textField.text = nil})
        } else {
            textFields.filter({$0.textField != textField.textField})
                .filter({ dataSource.isUniqueParameter(textField: $0) })
                .forEach({$0.textField.text = nil})
        }
        for textField in textFields where dataSource.shouldRemove(textField: textField) {
            textField.isHidden = true
        }
        setOffset(offset)
        updateButtonsState()
    }

    private func contentSizeOffSet() -> CGFloat {
        return offset
    }

    public func setOffset(_ value: CGFloat) {
        if value > 400 {
            self.formConfig.offset = value
            scrollView.contentSize = .init(width: view.frame.width, height: value)
        }
    }

    private func updateButtonsState() {
        guard let dataSource = formDataSource else { return }
        leftButton.setTitle(dataSource.leftButtonText(), for: .normal)
        righthButton.setTitle(dataSource.rightButtonText(), for: .normal)
    }

    public func loadTextFields() {
        textFields.removeAll()
        for view in formView.arrangedSubviews {
            formView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        addTextFields()
        bindUI()
    }

    public func scrollToTop(animated: Bool) {
        scrollView.scrollToTop(animated: animated)
    }

    public func scrollToBottom(animated: Bool) {
        scrollView.scrollToBottom(animated: animated)
    }

    public override func addSubviews() {
        scrollView.contentSize = .init(width: view.frame.width, height: view.safeAreaLayoutGuide.layoutFrame.height - 150)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(formView)
        view.addSubview(buttonGroup)
        buttonGroup.addArrangedSubview(leftButton)
        buttonGroup.addArrangedSubview(righthButton)
    }

    public override func setupConstraints() {
        formView.enableAutoLayout()
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollView.bottomAnchor, multiplier: 4),

            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 1),

            formView.topAnchor.constraint(equalToSystemSpacingBelow: scrollView.topAnchor, multiplier: formConfig.top ),
            formView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: formConfig.left),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: formView.trailingAnchor, multiplier: formConfig.right),

            buttonGroup.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonGroup.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonGroup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonGroup.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    @objc
    func didClickOnRightButton(_ sender: UIButton) {
        formDelegate?.didClickOnRightButton()
        sender.backgroundColor = .appBlue
        updateButtonsState()
    }

    @objc
    func didClickOnLeftButton(_ sender: UIButton) {
        formDelegate?.didClickOnLeftButton()
        sender.backgroundColor = .appBackgroundCell
        updateButtonsState()
    }

    @objc
    func didClick(_ sender: UIButton, _ event: UIControl.Event ) {
        if let background = sender.backgroundColor {
            sender.backgroundColor = background.withAlphaComponent(0.8)
        }
    }
}
