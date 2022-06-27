//
//  WarrantFilterViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 13/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AgenteDeCampoModule
import AgenteDeCampoCommon
import IQKeyboardManagerSwift
import CoreDataModels

class WarrantFilterViewController: UIViewController, ModuleFilterViewControllerProtocol {

    weak var delegate: SearchDelegate?
    var formController: FormViewController<WarrantFilterViewController>?
    private var form = BehaviorRelay<WarrantFilterFormModel>(value: WarrantFilterFormModel())

    let stateTf = CustomTextFieldFormBindable<WarrantFilterFormModel>(label: "Estado", placeholder: "Selecione", path: \.state)
    let cityTf = CustomTextFieldFormBindable<WarrantFilterFormModel>(label: "Cidade", placeholder: "Selecione", path: \.city)
    let documentTypeTf = CustomTextFieldFormBindable<WarrantFilterFormModel>(label: "Documento", placeholder: "Tipo", path: \.documentType)
    let documentTf = CustomTextFieldFormBindable<WarrantFilterFormModel>(label: "Nº do documento", placeholder: "", keyboardType: .numberPad, path: \.documentNumber)
    var nickNameTf = CustomTextFieldFormBindable<WarrantFilterFormModel>(label: "Alcunha", placeholder: "Ex. Zezinho", path: \.nickName)
    let nameTf = CustomTextFieldFormBindable<WarrantFilterFormModel>(label: "Nome", placeholder: "Ex. José da Silva", path: \.name)
    let motherName = CustomTextFieldFormBindable<WarrantFilterFormModel>(label: "Nome da mãe", placeholder: "Ex. Maria da Silva", path: \.motherName)
    let processNumber = CustomTextFieldFormBindable<WarrantFilterFormModel>(label: "Nº do processo", placeholder: "000000000000", keyboardType: .numberPad, path: \.processNumber)
    private lazy var textFields = [ nameTf, nickNameTf, documentTypeTf, documentTf, motherName,
        stateTf, cityTf, processNumber
    ]

    let maskHandler = TextFieldMask(patterns: [])

    private let statePicker = UIPickerView()
    private let cityPicker = UIPickerView()
    private let documentPicker = UIPickerView()
    private let stateDataSource = StateDataSource()
    private let cityDataSource = CityDataSource()
    private var documentDataSource: DocumentTypeDataSource?
    private var documentService = WarrantDocumentService()

    required init(params: [String: Any]) {
        super.init(nibName: nil, bundle: nil)
        nameTf.textField.text = params["name"] as? String
        nickNameTf.textField.text = params["nickName"] as? String
        processNumber.textField.text = params["processNumber"] as? String
        motherName.textField.text = params["motherName"] as? String
        processNumber.textField.text = params["proccessorNumber"] as? String
        if let cpf = documentService.getDocuments().filter({$0.name.elementsEqual("CPF")}).first,
            let number = params["documentNumber"] as? String, !number.isEmpty {
            didSelect(document: DocumentType(document: cpf) )
            documentTf.textField.text = number
            documentTf.isHidden = false
        }
        if let initials = params["dispatcherState"] as? String,
            let state = stateDataSource.findByInitials(initials) {
            didSelect(state: state)
        }

        if let code = params["dispatcherCity"] as? String,
            let city = cityDataSource.findByCode(code) {
            didSelect(city: city)
            cityTf.isHidden = false
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title  = "Mandados de prisão"
        setupStateTextField()
        setupCityTextField()
        setupDocumentTextField()
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
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        cityPicker.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        statePicker.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        documentPicker.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    func setupCityTextField() {
        cityPicker.backgroundColor = .appBackground
        cityTf.textField.inputView = cityPicker
        cityPicker.dataSource = cityDataSource
        cityPicker.delegate = cityDataSource
        cityPicker.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        addChevron(textField: cityTf.textField)
        if let chevron = cityTf.textField.rightView {
            chevron.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didClickOnChevronCity))
            chevron.addGestureRecognizer(tap)
        }
        cityDataSource.delegate = self
        cityTf.isHidden = cityTf.textField.text?.isEmpty ?? true
    }

    func setupStateTextField() {
        statePicker.backgroundColor = .appBackground
        stateTf.textField.inputView = statePicker
        statePicker.dataSource = stateDataSource
        statePicker.delegate = stateDataSource
        stateDataSource.delegate = self
        addChevron(textField: stateTf.textField)
        if let chevron = stateTf.textField.rightView {
            chevron.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didClickOnChevronState))
            chevron.addGestureRecognizer(tap)
        }
    }

    func setupDocumentTextField() {
        let documents = WarrantDocumentService().getDocuments().map({ DocumentType(document: $0) })
        documentDataSource = DocumentTypeDataSource(documents: documents)
        let appearance = UIToolbarAppearance()
        appearance.backgroundColor = .appBackground
        documentPicker.keyboardToolbar.standardAppearance = appearance
        documentPicker.keyboardToolbar.compactAppearance = appearance
        documentPicker.backgroundColor = .appBackground
        documentPicker.delegate = documentDataSource
        documentPicker.dataSource = documentDataSource
        documentTypeTf.textField.inputView = documentPicker
        let documentNumber = documentTf.textField.text ?? ""
        if documentNumber.isEmpty {
            documentTf.isHidden = true
        }
        documentDataSource?.delegate = self
        addChevron(textField: documentTypeTf.textField)
        documentTf.textField.delegate = maskHandler
        if let chevron = documentTypeTf.textField.rightView {
            chevron.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didClickOnChevronDocumentType))
            chevron.addGestureRecognizer(tap)
        }
    }

    func addChevron(textField: UITextField) {
        let chevron = UIImageView(image: UIImage(systemName: "chevron.down")?.withTintColor(.white, renderingMode: .alwaysOriginal))
        let conteiner = UIView(frame: .init(x: 0, y: 0, width: 40, height: 30))
        chevron.frame = .init(x: 0, y: 10, width: 20, height: 10)
        conteiner.addSubview(chevron)
        textField.rightView = conteiner
        textField.rightViewMode = .always
    }

    @objc
    func didClickOnChevronDocumentType() {
        documentTypeTf.textField.becomeFirstResponder()
    }

    @objc
    func didClickOnChevronState() {
        stateTf.textField.becomeFirstResponder()
    }

    @objc
    func didClickOnChevronCity() {
        cityTf.textField.becomeFirstResponder()
    }
}

extension WarrantFilterViewController: StateDataSourceDelegate, CityDataSourceDelegate, DocumentTypeDataSourceDelegate {

    func didSelect(state: State) {
        stateTf.textField.text = state.name
        form.value.set(value: state.initials, path: \.state)
        cityDataSource.selectadeState = state.initials
        updateCity(value: nil)
        self.stateTf.textField.backgroundColor = state.name.isEmpty ? .appBackgroundCell : .appBlue

        UIView.animate(withDuration: 0.3) {
            self.cityTf.isHidden = state.name.isEmpty
        }
    }

    func didSelect(city: City) {
        cityTf.isHidden = false
        updateCity(value: city)
    }

    func updateCity(value: City?) {
        cityTf.textField.text = value?.name
        if let code = value?.ibgeCode {
            form.value.set(value: "\(code)", path: \.city)
        } else {
            form.value.set(value: nil, path: \.city)
        }
    }

    func didSelect(document: DocumentType) {
        let isEmpty = document.name.isEmpty
        documentTypeTf.textField.text = document.name
        documentTypeTf.textField.backgroundColor = isEmpty ? .appBackgroundCell : .appBlue
        documentTf.textField.text = nil
        if let mask = document.mask {
            maskHandler.set(patterns: [mask])
        } else {
            maskHandler.set(patterns: [])
        }
        form.value.set(value: nil, path: \.documentNumber)
        form.value.set(value: "\(document.code)", path: \.documentType)
        UIView.animate(withDuration: 0.3) {
            self.documentTf.isHidden = isEmpty
        }
    }
}

extension WarrantFilterViewController: FormViewControllerDataSource {
    typealias Model = WarrantFilterFormModel

    func isUniqueParameter(textField: CustomTextFieldFormBindable<WarrantFilterFormModel>) -> Bool {
         return false
    }

    func shouldRemove(textField: CustomTextFieldFormBindable<WarrantFilterFormModel>) -> Bool {

        if textField == cityTf {
            guard let state = stateTf.textField.text else { return false }
            if state.isEmpty {
                stateTf.textField.backgroundColor = .appBackgroundCell
                return true
            }
        }

        if textField == documentTf {
            guard let documentType = documentTypeTf.textField.text else { return false }
            if documentType.isEmpty {
                documentTypeTf.textField.backgroundColor = .appBackgroundCell
                return true
            }
        }

        return false
    }

    func textFieldForm(for position: Int) -> CustomTextFieldFormBindable<WarrantFilterFormModel> {
        return textFields[position]
    }

    func numberOfTextFields() -> Int {
        return textFields.count
    }

    func didReturnBehaviorRelay() -> BehaviorRelay<WarrantFilterFormModel> {
        return form
    }

    func leftButtonText() -> String {
        let count = textFields.compactMap({$0.textField.text})
            .filter({!$0.isEmpty}).count
        if count > 0 {
            return "Limpar (\(count))"
        }
        return "Limpar"
    }

    func rightButtonText() -> String {
        return "Buscar"
    }
}

extension WarrantFilterViewController: FormViewControllerDelegate, CustomTextFieldFormDelegate {

    func didClickEnter(_ textFiled: UITextField) {
        didClickOnRightButton()
    }

    func didClickOnRightButton() {
        do {
            let params = try form.value.queryParams()
            let infos = form.value.getInfo()
            let name =  WarrantModule().name
            let recent = Recent(text: infos.toString,
                                textExpanded: infos.toStringExpanded,
                                module: name, iconName: "clock",
                                date: Date(), searchString: params)
            RecentsDataSource().save(recent)
            let controller = WarrantViewController(search: params, userInfo: infos, isFromSearch: false)
            navigationController?.pushViewController(controller, animated: true)
        } catch let error as NSError {
            alert(error: error.domain)
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
        form.value.set(value: nil, path: \.city)
        form.value.set(value: nil, path: \.documentType)
        form.value.set(value: nil, path: \.documentNumber)
        UIView.animate(withDuration: 0.3) {
            self.cityTf.isHidden = true
            self.documentTf.isHidden = true
        }
    }
}
