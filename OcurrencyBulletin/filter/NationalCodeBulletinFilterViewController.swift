//
//  NationalCodeBulletin.FilterViewConrtoller.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 18/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AgenteDeCampoModule
import AgenteDeCampoCommon
import CoreDataModels
import Logger
class NationalCodeBulletinFilterViewController: UIViewController, ModuleFilterViewControllerProtocol, FormViewControllerDelegate {

    private let loading = UIActivityIndicatorView(style: .large)
    weak var delegate: SearchDelegate?
    var formController: FormViewController<NationalCodeBulletinFilterViewController>?
    private var form = BehaviorRelay<OccurrenceBulletinFilterViewModel>(value: OccurrenceBulletinFilterViewModel())

    let nationalCodeTF = CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel>(label: "Nº do BO Nacional", placeholder: "00000000-00/0000/0000000000", keyboardType: .numberPad, path: \.nationalCode)
    let stateCodeTF = CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel>(label: "Nº do BO Estadual", placeholder: "0000000000000", keyboardType: .alphabet, path: \.stateCode)
    let stateTF = CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel>(label: "Estado", placeholder: "UF", path: \.state)
    let codeNationalMask = TextFieldMask(patterns: [AppMask.codeNational])

    var textFields = [CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel>]()
    var stateDataSource: StateDataSource?
    private let statePicker = UIPickerView()
    var selectadeState: State?
    let recentesDataSource = RecentsDataSource()
    private let params: [String: Any]
    var documentService: BulletimDocumentService?

    required init(params: [String: Any]) {
        self.params = params
        super.init(nibName: nil, bundle: nil)
        title = "Dados Gerais"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        formController = FormViewController(dataSource: self)
        textFields.append(nationalCodeTF)
        stateCodeTF.enableAutoLayout().width(view.frame.width * 0.7)
        stateTF.addChild(stateCodeTF, orientarion: .horizontal)
        textFields.append(stateTF)
        formController?.formConfig = FormConstraintsConfig(left: 1, top: 1, right: 1, bottom: 1)
        formController?.formDelegate = self
        view.addSubview(formController!.view)
        setupContraints()
        formController?.loadTextFields()
        setupPicker()
        nationalCodeTF.delegate = self
        stateCodeTF.delegate = self
        nationalCodeTF.textField.delegate = codeNationalMask
        codeNationalMask.delegate = self
        fillWithParamsValues()
    }

    func fillWithParamsValues() {
        nationalCodeTF.textField.text = params["nationalCode"] as? String
        stateCodeTF.textField.text = params["stateCode"] as? String
        stateDataSource?.setBulletinState(for: self, withinitials: params["bulletin.state"] as? String)
    }

    func setupPicker() {
        statePicker.dataSource = stateDataSource
        statePicker.delegate = stateDataSource
        stateTF.textField.inputView = statePicker
        stateDataSource?.delegate = self
        stateTF.textField.addChevron()
    }

    func setupContraints() {
        let formView = formController!.view!
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            formView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            safeArea.trailingAnchor.constraint(equalTo: formView.trailingAnchor)
        ])
    }

    func handlerDetailRequest(_ result: Result<BulletinDetails, Error> ) {
        self.setupLoading(false)
        switch result {
        case .success(let buletimDetails):
            self.gotoDetails(buletimDetails)
        case .failure(let error as NSError):
            garanteeMainThread {
                if self.isUnauthorized(error) {
                    self.gotoLogin(error.domain, completion: nil)
                } else {
                    self.alert(error: "Nenhum boletin foi encontado para os filtros informados")
                }
            }
        }
    }

    func searchBy(stateCode: String, completion: @escaping (Result<BulletinDetails, Error>) -> Void ) {
        guard let state = selectadeState, !state.name.isEmpty else {
            alert(error: "Selecione o estato")
            return
        }
        if stateCode.isEmpty {
            alert(error: "Você deve preencher o código estadual para fazer a busca.")
            return
        }
        saveRecentFor(state: state, andCode: stateCode)
        let service = OccurrenceBulletinService()
        setupLoading(true)
        let initials = selectadeState!.initials
        service.getByStateCode(state: initials, code: stateCode, completion: completion )
    }

    func saveRecentFor(state: State, andCode code: String) {
        let name = OcurencyBulletinModule().name
        let searchInfo = ["Cod. Estadual": code, "Estado": state.name]
        let service = ServiceType.state.rawValue
        let initials = state.initials
        let searchString = ["stateCode": code, "bulletin.state": initials, "service": service ]
        let recente = Recent(text: searchInfo.toString, textExpanded: searchInfo.toStringExpanded, module: name, searchString: searchString)
        recentesDataSource.save(recente)
    }

    func saveRecentFor(nationalCode: String) {
        let name = OcurencyBulletinModule().name
        let serviceName = ServiceType.national.rawValue
        let params = ["nationalCode": nationalCode, "service": serviceName ]
        let recente = Recent(text: nationalCode, textExpanded: nationalCode, module: name, searchString: params)
        recentesDataSource.save(recente)
    }

    func searchBy( nationalCode: String, completion: @escaping (Result<BulletinDetails, Error>) -> Void  ) {
        saveRecentFor(nationalCode: nationalCode)
        let service = OccurrenceBulletinService()
        setupLoading(true)
        service.getByNationalCode(code: nationalCode, completion: completion)
    }

    func gotoDetails(_ details: BulletinDetails) {
        garanteeMainThread {
            let viewModel = OcurrencyBulletinDetailViewModel(details: details)
            let controller = OcurrencyBulletinDetailViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension NationalCodeBulletinFilterViewController: CustomTextFieldFormDelegate {

    func didBeginEdite(_ textFiled: UITextField) {
        let text = textFiled.text ?? ""
        let isNotEmpty = !text.isEmpty
        if textFiled == nationalCodeTF.textField && isNotEmpty {
            stateCodeTF.textField.text = nil
            form.value.set(value: nil, path: \.stateCode)
        } else if textFiled == stateCodeTF.textField && isNotEmpty {
            nationalCodeTF.textField.text = nil
            form.value.set(value: nil, path: \.nationalCode)
        }
    }
}

extension NationalCodeBulletinFilterViewController: FormViewControllerDataSource, StateDataSourceDelegate {
    typealias Model = OccurrenceBulletinFilterViewModel

    func didSelect(state: State) {
        selectadeState = state.name.isEmpty ? nil : state
        stateTF.textField.text = state.initials
    }

    func textFieldForm(for position: Int) -> CustomTextFieldFormBindable<OccurrenceBulletinFilterViewModel> {
        return textFields[position]
    }

    func numberOfTextFields() -> Int {
        return textFields.count
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
        var count = 0
        if nationalCodeTF.textField.isNotEmpty { count += 1 }
        if stateCodeTF.textField.isNotEmpty { count += 1 }
        if stateTF.textField.isNotEmpty { count += 1 }
        return count == 0 ? "Limpar" : "Limpar (\(count))"
    }

    func didClickOnLeftButton() {
        stateCodeTF.textField.text = ""
        nationalCodeTF.textField.text = ""
        didSelect(state: .empty )
    }

    func didClickOnRightButton() {
        let nationalCode = form.value.nationalCode ?? ""
        let stateCode = form.value.stateCode ?? ""
        let allTextFiledsIsEmpty = stateCode.isEmpty && nationalCode.isEmpty && selectadeState == nil
        if allTextFiledsIsEmpty {
            alert(error: "Você deve prencher os filtros para fazer a busca.")
            return
        }
        if !nationalCode.isEmpty {
            searchBy(nationalCode: nationalCode, completion: handlerDetailRequest(_:))
            return
        } else {
            searchBy(stateCode: stateCode, completion: handlerDetailRequest(_:))
        }
    }

    func setupLoading( _ isLoading: Bool ) {
        garanteeMainThread {
            if isLoading {
                self.view.addSubview(self.loading)
                self.loading.enableAutoLayout()
                self.loading.fillSuperView()
                self.loading.startAnimating()
            } else {
                self.loading.stopAnimating()
                self.loading.removeFromSuperview()
            }
        }
    }
}
