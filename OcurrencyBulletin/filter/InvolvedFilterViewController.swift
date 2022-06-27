//
//  InvolvedFilterViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 21/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AgenteDeCampoModule
import AgenteDeCampoCommon
import CoreDataModels
import Logger

class InvolvedFilterViewController: UIViewController, ModuleFilterViewControllerProtocol {

    lazy var logger = Logger.forClass(Self.self)

    @BulletimDocumentServiceInject
    public var bulletimService: BulletimDocumentService

    typealias TextField = CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel>
    weak var delegate: SearchDelegate?

    var typeOptions: UISegmentedControl = {
        let options = UISegmentedControl(items: ["Pessoa física", "Pessoa jurídica"])
        options.configureAppDefault()
        options.enableAutoLayout()
        return options
    }()

    let cpfMask = TextFieldMask(patterns: [AppMask.cpfMask])
    let birthDateMask = TextFieldMask(patterns: [AppMask.dateMask])
    let cnpjMask = TextFieldMask(patterns: [AppMask.cnpjMask])

    var formController: FormViewController<InvolvedFilterViewController>?
    private var form = BehaviorRelay<OccurrenceBulletinFilterViewModel>(value: OccurrenceBulletinFilterViewModel())

    let cnpjTF = TextField(label: "CNPJ", placeholder: "00.000.000/0000-00", keyboardType: .numberPad, path: \.cnpj)
    let nomeFantasiaTF = TextField(label: "Razão Social/Nome Fantasia", placeholder: "Ex. Nome da Empresa ", keyboardType: .alphabet, path: \.nomeFantasia)

    let cpfTF = TextField(label: "CPF", placeholder: "000.000.000-00", keyboardType: .numberPad, path: \.cpf)
    let nameTF = TextField(label: "Nome completo/Social/Alcunha", placeholder: "Ex. José da Silva Pereira", keyboardType: .alphabet, path: \.name)
    let motherNamefTF = TextField(label: "Nome da mãe", placeholder: "Ex. Antônia da Silva Pereira", keyboardType: .alphabet, path: \.motherName)
    let fatherNamefTF = TextField(label: "Nome do pai", placeholder: "Ex. Antônio da Silva Pereira", keyboardType: .alphabet, path: \.fatherName)
    let birthDatefTF = TextField(label: "Data de nascimento", placeholder: "00/00/0000", keyboardType: .numberPad, path: \.birthDate)
    let documentTypeTF = TextField(label: "Outros documentos", placeholder: "Selecione", path: \.documentType)
    let documentValueTF = TextField(label: "Nº do documento", placeholder: "número do documento", path: \.documentValue)
    let documentTypePicker = UIPickerView()

    let stateTF = TextField(label: "Estado", placeholder: "Selecione", path: \.state)
    let cityTF = TextField(label: "Cidade", placeholder: "Selecione", path: \.city)
    var stateDataSource = StateDataSource()
    let cityDataSource = CityDataSource()
    let statePicker = UIPickerView()
    let cityPicker = UIPickerView()
    var selectadeState: State?
    var selectadeCity: City?
    var documentDatasource: DocumentTypeDataSource?
    var selectedDocument: DocumentType?
    let maskHandler = TextFieldMask(patterns: [])

    var serviceType: ServiceType = .physical
    var textFields = [[TextField]]()
    let searchParms: [String: Any]
    required init(params: [String: Any]) {
        searchParms = params
        super.init(nibName: nil, bundle: nil)
        title = "Envolvido"
    }

    private func setupWithParams(_ searchParms: [String: Any]) {
        cpfTF.textField.text = (searchParms["cpf"] as? String)?.applyCpfORCnpjMask
        cnpjTF.textField.text = (searchParms["cnpj"] as? String)?.applyCpfORCnpjMask
        motherNamefTF.textField.text = searchParms["motherName"] as? String
        fatherNamefTF.textField.text = searchParms["fatherName"] as? String
        if let date = searchParms["birthDate"] as? String {
            birthDatefTF.textField.text = date.split(separator: "-").reversed().joined(separator: "/")
        }
        if let service = searchParms["service"] as? String {
            if service.elementsEqual( ServiceType.physical.rawValue ) {
                nameTF.textField.text = searchParms["name"] as? String
            } else if service.elementsEqual("legal") {
                nomeFantasiaTF.textField.text = searchParms["name"] as? String
            }
        }
        let stadeDataSource = StateDataSource()
        let cityDataSource = CityDataSource()
        stadeDataSource.setBulletinState(for: self, withinitials: searchParms["bulletin.state"] as? String)
        cityDataSource.setBulletinCity(for: self, withCode: searchParms["bulletin.city"] as? String )
        documentValueTF.textField.text = (searchParms["document.value"] as? String)?.applyCpfORCnpjMask
        bulletimService.setupDocument(self, withType: "document.type")
        if let service = searchParms["service"] as?  String, let type = ServiceType.init(rawValue: service) {
            self.serviceType = type
        }
        let indexes: [ServiceType: Int] = [.physical: 0, .legal: 1]
        if let index = indexes[serviceType] {
            typeOptions.selectedSegmentIndex = index
            didChangeOption(typeOptions)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func hideDocumentTextField() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.documentTypeTF.isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWithParams(searchParms)
        documentTypeTF.isHidden = true
        documentValueTF.isHidden = true
        bulletimService.loadAll { [weak self] (result) in
            switch result {
            case .success(let documents):
                self?.documentDatasource = DocumentTypeDataSource(documents: documents.map({DocumentType(document: $0)}) )
                self?.setupDocumentPicker()
            case .failure(let error):
                self?.logger.error("Erro ao carregar os documentos \(error.localizedDescription)")
            }
        }

        view.backgroundColor = .appBackground
        formController = FormViewController(dataSource: self)
        formController?.formConfig = FormConstraintsConfig(left: 1, top: 1, right: 1, bottom: 1)
        formController?.formDelegate = self
        addSubviews()
        setupConstriants()
        formController?.setOffset(700)
        setupWithParams(searchParms)
    }

    func addSubviews() {
        cpfTF.textField.delegate = cpfMask
        birthDatefTF.textField.delegate = birthDateMask
        cnpjTF.textField.delegate = cnpjMask
        view.addSubview(formController!.view!)
        view.addSubview(typeOptions)
        textFields.append([cpfTF, nameTF, birthDatefTF, motherNamefTF, fatherNamefTF,
                           documentTypeTF, documentValueTF, stateTF, cityTF])
        textFields.append([cnpjTF, nomeFantasiaTF, stateTF, cityTF])
        formController?.loadTextFields()
        typeOptions.addTarget(self, action: #selector(didChangeOption(_:)), for: .valueChanged)
        textFields.forEach({ $0.forEach({ $0.delegate = self }) })
        setupStateAndCityPicker()
    }

    private func setupDocumentPicker() {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.documentTypeTF.isHidden = false
            }
            self?.documentTypeTF.textField.addChevron()
            self?.documentTypeTF.textField.inputView = self?.documentTypePicker
            self?.documentTypePicker.dataSource = self?.documentDatasource
            self?.documentTypePicker.delegate = self?.documentDatasource
            self?.documentDatasource?.delegate = self
        }
    }

    fileprivate func setupStateAndCityPicker() {
        cityTF.textField.inputView = cityPicker
        stateTF.textField.inputView = statePicker
        cityPicker.dataSource = cityDataSource
        statePicker.dataSource = stateDataSource
        statePicker.delegate = stateDataSource
        cityPicker.delegate = cityDataSource
        cityDataSource.delegate = self
        stateDataSource.delegate = self
        cityTF.isHidden = selectadeCity == nil
        cityTF.textField.addChevron()
        stateTF.textField.addChevron()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupConstriants() {
        let safeArea = view.safeAreaLayoutGuide
        let formView = formController!.view!
        formView.enableAutoLayout()

        NSLayoutConstraint.activate([
            typeOptions.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 2),
            typeOptions.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 3),
            typeOptions.heightAnchor.constraint(equalToConstant: 33),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: typeOptions.trailingAnchor, multiplier: 3),

            formView.topAnchor.constraint(equalToSystemSpacingBelow: typeOptions.bottomAnchor, multiplier: 1),
            formView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            safeArea.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    @objc
    func didChangeOption(_ sender: UISegmentedControl) {
        clearAllButCurrentTab()
        formController?.loadTextFields()
        formController?.scrollToTop(animated: false)
        let services: [ServiceType] = [.physical, .legal]
        serviceType = services[sender.selectedSegmentIndex]
    }

    func clearAllButCurrentTab() {
        if textFields.count == 2 {
            for i in 0...1 {
                self.textFields[i].forEach { (textField) in
                    textField.textField.text = ""
                    if let path = textField.path {
                        form.value.set(value: nil, path: path)
                    }
                    textField.textField.backgroundColor = .appBackgroundCell
                }
            }
            selectedDocument = nil
            selectadeCity = nil
            selectadeState = nil
        }
    }
}

// MARK: DocumentTypeDataSourceDelegate
extension InvolvedFilterViewController: DocumentTypeDataSourceDelegate {
    func didSelect(document: DocumentType) {
        documentTypeTF.textField.text = document.name
        let isSelected = !document.name.isEmpty
        selectedDocument = isSelected ? document : nil
        documentTypeTF.textField.backgroundColor = isSelected ? .appBlue : .appBackgroundCell
        documentValueTF.textField.layer.borderWidth = isSelected ? 1 : 0
        documentValueTF.textField.layer.borderColor = isSelected ? UIColor.appBlue.cgColor : UIColor.appBackgroundCell.cgColor
        if let mask = document.mask {
            documentValueTF.textField.delegate = maskHandler
            maskHandler.set(patterns: [mask] )
        } else {
            documentValueTF.textField.delegate = nil
        }
        documentValueTF.textField.keyboardType = document.keyboardType
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.documentValueTF.isHidden = !isSelected
        }
    }
}

extension InvolvedFilterViewController: StateDataSourceDelegate, CityDataSourceDelegate {

    func didSelect(city: City) {
        selectadeCity = city
        let model = form.value
        cityTF.textField.text = city.name
        model.set(value: "\(city.ibgeCode)", path: \.city)
    }

    func didSelect(state: State) {
        let model = form.value
        let value = state.name.isEmpty ? nil : state.name
        model.set(value: value, path: \.state)
        garanteeMainThread { [weak self] in
            self?.stateTF.textField.text = value
            self?.cityDataSource.selectadeState = state.initials
            self?.selectadeState = state.name.isEmpty ? nil : state
            let color = value == nil ? UIColor.appBackgroundCell : UIColor.appBlue
            self?.stateTF.textField.backgroundColor = color
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.cityTF.isHidden = value == nil
        }
    }
}

extension InvolvedFilterViewController: FormViewControllerDataSource, FormViewControllerDelegate {

    typealias Model = OccurrenceBulletinFilterViewModel

    func textFieldForm(for position: Int) -> CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel> {
        return self.textFields[typeOptions.selectedSegmentIndex][position]
    }

    func numberOfTextFields() -> Int {
        return self.textFields[typeOptions.selectedSegmentIndex].count
    }

    func didReturnBehaviorRelay() -> BehaviorRelay<OccurrenceBulletinFilterViewModel> {
        return form
    }

    func isUniqueParameter(textField: CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel>) -> Bool {
        return false
    }

    func shouldRemove(textField: CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel>) -> Bool {
        return false
    }

    func rightButtonText() -> String {
        return "Buscar"
    }

    func leftButtonText() -> String {
        let count = textFields[typeOptions.selectedSegmentIndex].compactMap({$0.textField.text})
            .filter({!$0.isEmpty})
            .count
        if count > 0 {
            return "Limpar (\(count))"
        }
        return "Limpar"
    }

    func didClickOnLeftButton() {
        if textFields.count == 2 {
            for textField in textFields[typeOptions.selectedSegmentIndex] {
                textField.textField.text = ""
                if let path = textField.path {
                    form.value.set(value: nil, path: path)
                }
                textField.textField.backgroundColor = .appBackgroundCell
            }
            selectedDocument = nil
            selectadeCity = nil
            selectadeState = nil
        }
    }

    func didClickOnRightButton() {
        do {
            var params = try form.value.queryParams()
            if params.isEmpty {
                alert(error: "Você deve preencher pelo menos um filtro")
                return
            }
            if let city = selectadeCity {
                params["bulletin.city"] = "\(city.ibgeCode)"
            }
            if let state = selectadeState {
                params["bulletin.state"] = state.initials
            }
            let info = form.value.getInfos()
            params["service"] = serviceType.rawValue
            if let document = selectedDocument {
                params["document.type"] = "\(document.code)"
                guard let value = params["document.value"] as? String else {
                    alert(error: "Você deve preencher o valor do documento")
                    return
                }
                if !document.isValid(value: value) {
                    alert(error: "Digite um valor válido para \(document.name)")
                    return
                }
            }
            let module = OcurencyBulletinModule().name
            let recent = Recent(text: info.toString, textExpanded: info.toStringExpanded, module: module, iconName: "clock", date: Date(), searchString: params)
            RecentsDataSource().save(recent)
            let controller = OcurrenceBulletinViewController(search: params, userInfo: info, isFromSearch: false)
            navigationController?.pushViewController(controller, animated: true)
        } catch let error as InputValidationError {
            self.alert(error: error.description)
        } catch let error as NSError {
            self.alert(error: error.domain)
        }
    }
}

extension InvolvedFilterViewController: CustomTextFieldFormDelegate {

    func didClickEnter(_ textFiled: UITextField) {
        didClickOnRightButton()
    }
}
