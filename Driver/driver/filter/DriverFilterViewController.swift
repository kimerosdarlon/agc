//
//  DriverViewController.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 13/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import UIKit
import Foundation
import AgenteDeCampoModule
import AgenteDeCampoCommon
import RxCocoa
import CoreDataModels

class DriverFilterViewController: UIViewController, ModuleFilterViewControllerProtocol {

    weak var delegate: SearchDelegate?
    var formController: FormViewController<DriverFilterViewController>?
    private var form = BehaviorRelay<DriverFilterFormModel>(value: DriverFilterFormModel())

    let cpfTf = CustomTextFieldFormBindable<DriverFilterFormModel>(label: "CPF", placeholder: "000.000.000-00", keyboardType: .numberPad, path: \.cpf)

    let cnhTf = CustomTextFieldFormBindable<DriverFilterFormModel>(label: "Número de Registro", placeholder: "00000000000", keyboardType: .numberPad, path: \.cnh)

    let renachTf = CustomTextFieldFormBindable<DriverFilterFormModel>(label: "RENACH", placeholder: "AA000000000", keyboardType: .namePhonePad, path: \.renach)

    let pidTf = CustomTextFieldFormBindable<DriverFilterFormModel>(label: "PID", placeholder: "00000000000", keyboardType: .namePhonePad, path: \.pid)

    let cpfMask = TextFieldMask(patterns: ["###.###.###-##"])
    let cnhMask = TextFieldMask(patterns: ["###########"])
    let renachMask = TextFieldMask(patterns: ["###########"])

    private lazy var textFields = [ cpfTf, cnhTf, renachTf, pidTf ]

    required init(params: [String: Any]) {
        super.init(nibName: nil, bundle: nil)
        cpfTf.textField.text = params["cpf"] as? String
        cnhTf.textField.text = params["cnh"] as? String
        renachTf.textField.text = params["renach"] as? String
        pidTf.textField.text = params["pid"] as? String
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Condutores"
        formController = FormViewController(dataSource: self)
        formController?.formConfig = .init(left: 1, top: 10, right: 1, bottom: 1)
        formController?.formDelegate = self
        let formView = formController!.view!
        view.addSubview(formView)
        formView.enableAutoLayout()
        let safeArea: UILayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 4),
            formView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            safeArea.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        formController?.loadTextFields()
        formController?.setOffset(800)
        textFields.forEach({$0.delegate = self})
        cpfMask.delegate = self
        cnhMask.delegate = self
        renachMask.delegate = self

        cpfTf.textField.delegate = cpfMask
        cnhTf.textField.delegate = cnhMask
        renachTf.textField.delegate = renachMask
    }
}

extension DriverFilterViewController: FormViewControllerDataSource {
    typealias Model = DriverFilterFormModel

    func textFieldForm(for position: Int) -> CustomTextFieldFormBindable<DriverFilterFormModel> {
        return textFields[position]
    }

    func numberOfTextFields() -> Int {
        return textFields.count
    }

    func didReturnBehaviorRelay() -> BehaviorRelay<DriverFilterFormModel> {
        return form
    }

    func isUniqueParameter(textField: CustomTextFieldFormBindable<DriverFilterFormModel>) -> Bool {
        return false
    }

    func shouldRemove(textField: CustomTextFieldFormBindable<DriverFilterFormModel>) -> Bool {
        return false
    }

    func rightButtonText() -> String {
        return "Buscar"
    }

    func leftButtonText() -> String {
        let count = textFields.compactMap({$0.textField.text})
            .filter({!$0.isEmpty}).count
        if count > 0 {
            return "Limpar (\(count))"
        }
        return "Limpar"
    }
}

extension DriverFilterViewController: FormViewControllerDelegate, CustomTextFieldFormDelegate {

    func didClickEnter(_ textFiled: UITextField) {
        didClickOnRightButton()
    }

    func didClickOnRightButton() {
        do {
            try form.value.validateInput()
            let infos = form.value.getInfo()
            let name =  DriverModule().name
            let recent = Recent(text: infos.toString,
                                textExpanded: infos.toStringExpanded,
                                module: name, iconName: "clock",
                                date: Date(), searchString: form.value.params)
            RecentsDataSource().save(recent)
            if infos["cpf"] != nil || infos["cnh"] != nil || infos["renach"] != nil || infos["pid"] != nil {
                let controller = DriverViewController(search: [:], userInfo: infos, isFromSearch: false)
                navigationController?.pushViewController(controller, animated: true)
            }
        } catch let error as InputValidationError {
            alert(error: error.description)
        } catch {
            alert(error: error.localizedDescription)
        }
    }

    @objc func didBeginEdite(_ editedField: UITextField) {
        if editedField.text != "" {
            for textField in textFields
            where textField.textField != editedField {
                if let path = textField.path {
                    form.value.set(value: nil, path: path)
                }
                textField.textField.text = ""
            }
        }
    }

    func didClickOnLeftButton() {
        for textField in textFields {
            textField.textField.text = ""
            if let path = textField.path {
                form.value.set(value: nil, path: path)
            }
            textField.textField.backgroundColor = .appBackgroundCell
        }
        form.value.set(value: nil, path: \.cpf)
        form.value.set(value: nil, path: \.cnh)
        form.value.set(value: nil, path: \.renach)
        form.value.set(value: nil, path: \.pid)
    }
}
