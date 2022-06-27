//
//  CadFilterViewController.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon
import Combine
import RxCocoa
import CoreDataModels

class CadFilterViewController: UIViewController, ModuleFilterViewControllerProtocol {
    weak var delegate: SearchDelegate?

    private var formView: OccurrencesFormView!

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    private let searchButton: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Buscar", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .appBlue
        return btn
    }()

    private let clearButton: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Limpar", for: .normal)
        btn.setTitleColor(.appCellLabel, for: .normal)
        btn.backgroundColor = .appBackgroundCell
        return btn
    }()

    required init(params: [String: CadFilterSearchField]) {
        super.init(nibName: nil, bundle: nil)
        var serviceParams = [String: Any]()
        for (key, value) in params where value["serviceValue"] != nil {
            serviceParams[key] = value["serviceValue"]!
        }
        let viewModel = CadFilterViewModel(params: serviceParams)
        self.formView = OccurrencesFormView(viewModel: viewModel, parentViewController: self).enableAutoLayout()
        self.view.backgroundColor = .appBackground
        bindUI()
    }

    required init(params: [String: Any]) {
        super.init(nibName: nil, bundle: nil)
        let viewModel = CadFilterViewModel(params: params)
        self.formView = OccurrencesFormView(viewModel: viewModel, parentViewController: self).enableAutoLayout()
        self.view.backgroundColor = .appBackground
        bindUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        view.backgroundColor = .appBackground
        title = "Filtro de Ocorrências"
        bindUI()

        view.addSubview(formView)
        view.addSubview(searchButton)
        view.addSubview(clearButton)

        clearButton.height(45)
        searchButton.height(45)

        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1),
            formView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: searchButton.topAnchor),
            view.bottomAnchor.constraint(equalTo: searchButton.bottomAnchor),

            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clearButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            clearButton.bottomAnchor.constraint(equalTo: searchButton.bottomAnchor),

            searchButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.formView.openSection(0)
        }
    }

    private func bindUI() {
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
    }

    @objc
    func clear() {
        formView.clear()
    }

    @objc
    func search() {
        do {
            if formView.fields.filter({ $0.isFilled() }).isEmpty {
                throw InputValidationError.empty
            }

            try formView.viewModel.validateInput()

            let infos = formView.getInfo()
            let queryParams = formView.viewModel.queryParams()
            let name = CadModule().name
            let recent = Recent(text: infos.toString,
                                textExpanded: infos.toStringExpanded,
                                module: name, iconName: "clock",
                                date: Date(), searchString: formView.viewModel.getSearchString(infos))
            RecentsDataSource().save(recent)
            garanteeMainThread {
                self.navigationController?.pushViewController(
                    OccurrencesViewController(search: queryParams, userInfo: infos, isFromSearch: false),
                    animated: true
                )
            }
        } catch let error as InputValidationError {
            alert(error: error.description)
        } catch let error as CadFilterViewModel.CadFilterValidation {
            alert(error: error.description)
        } catch {
            alert(error: error.localizedDescription)
        }
    }
}
