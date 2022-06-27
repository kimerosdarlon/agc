//
//  VehicleFilterViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 29/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import AgenteDeCampoModule
import AgenteDeCampoCommon
import Logger
import CoreDataModels

class VehicleFilterViewController: UIViewController, ModuleFilterViewControllerProtocol {

    lazy var logger = Logger.forClass(Self.self)

    private var contentView: UIView = {
        let view = UIView()
        view.enableAutoLayout()
        view.backgroundColor = .appBackground
        return view
    }()

    var formController: FormViewController<VehicleFilterViewController>!

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var height: NSLayoutConstraint!

    let heightOverflow: CGFloat = 100
    var viewHeight: CGFloat = 0

    fileprivate let disposeBag = DisposeBag()
    var form = BehaviorRelay(value: VehicleFormViewModel())
    weak var delegate: SearchDelegate?

    let searchButton = AGCRoundedButton(text: "Buscar")

    let plateField = CustomTextFieldFormBindable<VehicleFormViewModel>(label: "Placa", placeholder: "AAA-0000 ou AAA-0A00", path: \.plate)
    let chassiField = CustomTextFieldFormBindable<VehicleFormViewModel>(label: "Chassi", placeholder: "000A0AAA0AAA00000", path: \.chassis)
    let renavamField =  CustomTextFieldFormBindable<VehicleFormViewModel>(label: "Renavam", placeholder: "00000000000", keyboardType: .numberPad, path: \.renavam)
    let motorField =  CustomTextFieldFormBindable<VehicleFormViewModel>(label: "Motor", placeholder: "0000", path: \.motor)
    let cpfTextField =  CustomTextFieldFormBindable<VehicleFormViewModel>(label: "Proprietário", placeholder: "CPF ou CNPJ", keyboardType: .numberPad, path: \.owner)

    let plateMask = TextFieldMask(pattern: "###-####")
    let cpfMask = TextFieldMask(patterns: ["###.###.###-##", "##.###.###/####-##"])
    var textFields = [CustomTextFieldFormBindable<VehicleFormViewModel>]()
    var ownerTypeOptions: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Proprietário", "Possuidor", "Locatário"])
        segment.configureAppDefault()
        segment.enableAutoLayout()
        return segment
    }()

    required init(params: [String: Any]) {
        super.init(nibName: nil, bundle: nil)
        title = "Veículos"
        let plate = (params["plate"] as? String)?.apply(pattern: AppMask.plateMask, replacmentCharacter: "#")
        let motor = (params["motor"] as? String)
        let renavam = (params["renavam"] as? String)
        if let cpf = (params["cpf"] as? String)?.apply(pattern: AppMask.cpfMask, replacmentCharacter: "#") {
            cpfTextField.textField.text = cpf
        }
        if let owner = (params["owner"] as? String)?.apply(pattern: AppMask.cpfMask, replacmentCharacter: "#") {
            cpfTextField.textField.text = owner
        }
        if let renter = (params["renter"] as? String)?.apply(pattern: AppMask.cpfMask, replacmentCharacter: "#") {
            cpfTextField.textField.text = renter
        }
        if let possessor = (params["possessor"] as? String)?.apply(pattern: AppMask.cpfMask, replacmentCharacter: "#") {
            cpfTextField.textField.text = possessor
        }
        let chassis = params["chassis"] as? String
        plateField.textField.text = plate
        motorField.textField.text = motor
        renavamField.textField.text = renavam
        chassiField.textField.text = chassis
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .appBackground
        super.viewDidLoad()
        addSubviews()
        setupConstraints()
        view.backgroundColor = .appBackground
        plateMask.delegate = self
        cpfMask.delegate = self
        plateField.textField.delegate = plateMask
        cpfTextField.textField.delegate = cpfMask
        formController.setOffset(view.frame.height)
        textFields.forEach({$0.delegate = self})
        ownerTypeOptions.addTarget(self, action: #selector(didChangeOwnerType(_:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let style = UserStylePreferences.theme.style
        view.overrideUserInterfaceStyle = style
    }

    @objc
    func didChangeOwnerType(_ segment: UISegmentedControl ) {
        let model = form.value
        model.owner = nil
        model.renter = nil
        model.possessor = nil
        let labels = ["Proprietário", "Possuidor", "Locatário"]
        let paths: [ReferenceWritableKeyPath<VehicleFormViewModel, String?>] =  [ \.owner, \.possessor, \.renter ]
        cpfTextField.label.text = labels[segment.selectedSegmentIndex]
        cpfTextField.path = paths[segment.selectedSegmentIndex]
        formController.loadTextFields()
        form.value.set(value: cpfTextField.textField.text, path: cpfTextField.path!)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @objc
    func cancelAction(_ textField: UITextField) {
        view.endEditing(true)
    }

    func addSubviews() {
        textFields.append(cpfTextField)
        textFields.append(plateField)
        textFields.append(chassiField)
        textFields.append(renavamField)
        textFields.append(motorField)
        formController = FormViewController(dataSource: self)
        formController.formConfig = FormConstraintsConfig(left: 1, top: 1, right: 1, bottom: 1)
        formController.formDelegate = self
        formController.loadTextFields()
        formController.viewDidLoad()
        let formView = formController.view!
        view.addSubview(formView)
        view.addSubview(ownerTypeOptions)
    }

    func setupConstraints() {
        let formView = formController.view!
        let safeArea = view.safeAreaLayoutGuide
        formView.enableAutoLayout()
        NSLayoutConstraint.activate([
            ownerTypeOptions.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1),
            ownerTypeOptions.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 1),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: ownerTypeOptions.trailingAnchor, multiplier: 1),
            formView.topAnchor.constraint(equalToSystemSpacingBelow: ownerTypeOptions.bottomAnchor, multiplier: 1),
            formView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            safeArea.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    deinit {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
}

extension VehicleFilterViewController: CustomTextFieldFormDelegate {

    func didClickEnter(_ textFiled: UITextField) {
        self.didClickOnRightButton()
    }
}

// MARK: - Filter Delegate e DataSource
extension VehicleFilterViewController: FormViewControllerDataSource, FormViewControllerDelegate {
    typealias Model = VehicleFormViewModel

    func textFieldForm(for position: Int) -> CustomTextFieldFormBindable<VehicleFormViewModel> {
        return textFields[position]
    }

    func numberOfTextFields() -> Int {
        return textFields.count
    }

    func didReturnBehaviorRelay() -> BehaviorRelay<VehicleFormViewModel> {
        return form
    }

    func isUniqueParameter(textField: CustomTextFieldFormBindable<VehicleFormViewModel>) -> Bool {
        return true
    }

    func shouldRemove(textField: CustomTextFieldFormBindable<VehicleFormViewModel>) -> Bool {
        return false
    }

    func rightButtonText() -> String {
        return "Buscar"
    }

    func leftButtonText() -> String {
        let count = textFields.compactMap({$0.textField.text}).filter({!$0.isEmpty}).count
        if count > 0 {
            return "Limpar (\(count))"
        }
        return "Limpar"
    }

    func didClickOnLeftButton() {
        for textField in textFields {
            textField.textField.text = ""
            if let path = textField.path {
                form.value.set(value: nil, path: path)
            }
            textField.textField.backgroundColor = .appBackgroundCell
        }
    }

    func didClickOnRightButton() {
        do {
            let query = try form.value.queryParams()
            view.endEditing(true)
            let userInfo = self.form.value.getInfo()
            let recent = Recent(text: userInfo.first!.value,
                                textExpanded: userInfo.first!.value,
                                module: VehicleModule().name,
                                iconName: "clock", date: Date(),
                                searchString: query)
            RecentsDataSource().save(recent)
            let controller = VehicleViewController(search: query, userInfo: userInfo, isFromSearch: false)
            navigationController?.pushViewController(controller, animated: true)
        } catch let error as InputValidationError {
            alert(error: error.description)
        } catch {
            alert(error: error.localizedDescription)
        }
    }
}
