//
//  ObjectFilterViewController.swift
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

class ObjectFilterViewController: UIViewController, ModuleFilterViewControllerProtocol {

    typealias TextField = CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel>
    weak var delegate: SearchDelegate?
    private var service = ServiceType.vehicle
    private var query = [String: Any]()

    var typeOptions: UISegmentedControl = {
        let options = UISegmentedControl(items: ["Veículo", "Arma", "Celular"])
        options.configureAppDefault()
        options.selectedSegmentIndex = 0
        options.enableAutoLayout()
        return options
    }()

    var formController: FormViewController<ObjectFilterViewController>?
    private var form = BehaviorRelay<OccurrenceBulletinFilterViewModel>(value: OccurrenceBulletinFilterViewModel())
    let plateMask = TextFieldMask(pattern: AppMask.plateMask)

    // MARK: TextField
    let plateTF = TextField(label: "Placa", placeholder: "AAA-9999", keyboardType: .alphabet, path: \.licensePlate)
    let serialNumberTF = TextField(label: "Nº de série", placeholder: "0000000000000", keyboardType: .alphabet, path: \.serialNumber)
    let imeiTF = TextField(label: "IMEI", placeholder: "00000000000", keyboardType: .alphabet, path: \.imei)
    let chassisTF = TextField(label: "Chassi", placeholder: "00000000000", keyboardType: .alphabet, path: \.chassis)
    let ownerTF = TextField(label: "Proprietário", placeholder: "Ex. José da Silva Pereira", keyboardType: .alphabet, path: \.owner)
    let ownerCpfTF = TextField(label: "CPF", placeholder: "000.000.000-00", keyboardType: .numberPad, path: \.ownerCpf)
    let possessorfTF = TextField(label: "Possuidor", placeholder: "Ex. Antônia da Silva Pereira", keyboardType: .alphabet, path: \.possessor)
    let stateTF = TextField(label: "Estado", placeholder: "Selecione", path: \.state)
    let cityTF = TextField(label: "Cidade", placeholder: "Selecione", path: \.city)
    var stateDataSource = StateDataSource()
    let cityDataSource = CityDataSource()
    let statePicker = UIPickerView()
    let cityPicker = UIPickerView()
    var selectadeState: State?
    var selectadeCity: City?

    let cpfMask = TextFieldMask(patterns: [AppMask.cpfMask])
    var textFields = [[TextField]]()

    required init(params: [String: Any]) {
        query = params
        super.init(nibName: nil, bundle: nil)
        title = "Objeto"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var serviceType: ServiceType {
        guard let service = self.query["service"] as? String else { return .vehicle }
        return ServiceType.init(rawValue: service) ?? .vehicle
    }

    func configure(with params: [String: Any] ) {
        plateTF.textField.text = params["plate"] as? String
        chassisTF.textField.text = params["chassis"] as? String
        ownerTF.textField.text = params["owner.name"] as? String
        possessorfTF.textField.text = params["possessor.name"] as? String
        ownerCpfTF.textField.text = (params["owner.cpf"] as? String)?.applyCpfORCnpjMask
        serialNumberTF.textField.text = params["serialNumber"] as? String
        imeiTF.textField.text = params["imei"] as? String
        var index: Int
        switch serviceType {
        case .vehicle:
            index = 0
        case .weapons:
            index = 1
        case .cellphones:
            index = 2
        default:
            index = 0
        }
        typeOptions.selectedSegmentIndex = index
        didChangeOption(typeOptions)
        stateDataSource.setBulletinState(for: self, withinitials: query["bulletin.state"] as? String)
        cityDataSource.setBulletinCity(for: self, withCode: query["bulletin.city"] as? String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        configure(with: query)
        formController = FormViewController(dataSource: self)
        formController?.formDelegate = self
        addSubviews()
        setupConstraints()
        setupStateAndCityPicker()
        let style = UserStylePreferences.theme.style
        textFields.forEach({ $0.forEach({ $0.overrideUserInterfaceStyle = style}) })
        ownerCpfTF.textField.delegate = cpfMask
    }

    func addSubviews() {
        formController?.formConfig = FormConstraintsConfig()
        view.addSubview(formController!.view!)
        view.addSubview(typeOptions)
        plateTF.textField.delegate = plateMask
        textFields.append([plateTF, chassisTF, ownerTF, possessorfTF])
        textFields.append([serialNumberTF, ownerTF, ownerCpfTF, stateTF, cityTF])
        textFields.append([serialNumberTF, imeiTF, stateTF, cityTF])
        formController?.loadTextFields()
        ownerCpfTF.textField.delegate = cpfMask
        typeOptions.addTarget(self, action: #selector(didChangeOption(_:)), for: .valueChanged)
        setupStateAndCityPicker()
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
        let style = UserStylePreferences.theme.style
        cityPicker.overrideUserInterfaceStyle = style
        statePicker.overrideUserInterfaceStyle = style
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let formView = formController!.view!
        formView.enableAutoLayout()

        NSLayoutConstraint.activate([
            typeOptions.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 2),
            typeOptions.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 2),
            typeOptions.heightAnchor.constraint(equalToConstant: 33),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: typeOptions.trailingAnchor, multiplier: 2),

            formView.topAnchor.constraint(equalToSystemSpacingBelow: typeOptions.bottomAnchor, multiplier: 1),
            formView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    @objc
    func didChangeOption(_ sender: UISegmentedControl) {
        clearAllButCurrentTab()
        formController?.loadTextFields()
        let services: [ServiceType] = [.vehicle, .weapons, .cellphones]
        service = services[sender.selectedSegmentIndex]
    }

    func clearAllButCurrentTab() {
        if textFields.count == 3 {
            for i in 0...2 {
                self.textFields[i].forEach { (textField) in
                    textField.textField.text = ""
                    if let path = textField.path {
                        form.value.set(value: nil, path: path)
                    }
                }
            }
            if typeOptions.selectedSegmentIndex > 0 {
                didSelect(state: .empty)
            }
        }
    }
}

extension ObjectFilterViewController: FormViewControllerDataSource, FormViewControllerDelegate {

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

    func rightButtonText() -> String { "Buscar" }

    func leftButtonText() -> String {
        let count = textFields[typeOptions.selectedSegmentIndex]
            .compactMap({$0.textField.text})
            .filter({!$0.isEmpty})
            .count
        return count == 0 ? "Limpar" : "Limpar (\(count))"
    }

    func didClickOnRightButton() {
        do {
            query = try form.value.queryParams()
            if let city = selectadeCity {
                query["bulletin.city"] = "\(city.ibgeCode)"
            }
            if let state = selectadeState {
                query["bulletin.state"] = state.initials
            }
            let info = form.value.getInfos()
            query["service"] = service.rawValue
            let controller = OcurrenceBulletinViewController(search: query, userInfo: info, isFromSearch: false)
            let moduleName = OcurencyBulletinModule().name
            let recent = Recent(text: info.toString, textExpanded: info.toStringExpanded, module: moduleName, iconName: "clock", date: Date(), searchString: query)
            RecentsDataSource().save(recent)
            navigationController?.pushViewController(controller, animated: true)
        } catch let error as InputValidationError {
            alert(error: error.description)
        } catch let error as NSError {
            alert(error: error.domain)
        }
    }

    func didClickOnLeftButton() {
        self.textFields[typeOptions.selectedSegmentIndex].forEach { (textField) in
            textField.textField.text = ""
        }
        if typeOptions.selectedSegmentIndex > 0 {
            didSelect(state: .empty)
        }
    }
}

extension ObjectFilterViewController: StateDataSourceDelegate, CityDataSourceDelegate {

    func didSelect(city: City) {
        selectadeCity = city
        let model = form.value
        model.set(value: "\(city.ibgeCode)", path: \.city)
        garanteeMainThread { [weak self] in
            self?.cityTF.textField.text = city.name
        }
    }

    func didSelect(state: State) {
        let model = form.value
        let value = state.name.isEmpty ? nil : state.name
        model.set(value: value, path: \.state)
        cityDataSource.selectadeState = state.initials
        selectadeState = state.name.isEmpty ? nil : state
        selectadeCity = nil

        garanteeMainThread { [weak self] in
            self?.stateTF.textField.text = value
            let color = value == nil ? UIColor.appBackgroundCell : UIColor.appBlue
            self?.stateTF.textField.backgroundColor = color
            self?.cityTF.textField.text = ""
            self?.cityPicker.selectRow(0, inComponent: 0, animated: false)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.cityTF.isHidden = value == nil
        }
    }
}
