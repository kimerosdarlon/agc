//
//  WarrantModule.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 26/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon
import CoreDataModels

public class WarrantModule: Module {

    public init() {
    }

    public func getActionsFor(text: String, exceptedModuleNames names: [String]) -> [UIAction] {

        if names.contains(name) {
            return []
        }

        var actions = [UIAction]()

        let foldedText = text.prepareForSearch()
        if foldedText.isCPF || foldedText.matches(in: AppRegex.personNamePattern) {
            actions.append(searchActionFor(text: text))
        }
        return actions
    }

    private func searchActionFor(text: String) -> UIAction {
        let params = getParamsFor(text: text)
        let controller = WarrantViewController(search: params, userInfo: getInfoFor(text: text, query: params), isFromSearch: false)
        let image = UIImage(systemName: "magnifyingglass")
        let action = UIAction(title: "Buscar em \(name)", image: image) { (_) in
            garanteeMainThread {
                NotificationCenter.default.post(name: .actionNavigation,
                                                object: nil,
                                                userInfo: ["viewController": controller])
            }
        }
        return action
    }

    public var name: String { "Mandados de prisão" }

    public var patterns: [String] {
        return [AppRegex.cpfPattern, AppRegex.personNamePattern ]
    }

    public var imageName: String { "cuffs" }

    public var role: String? { Roles.searchBNMP }

    public var controller: SearchApiResultController.Type { WarrantViewController.self }

    public var filterController: ModuleFilterViewControllerProtocol.Type? { WarrantFilterViewController.self }

    public var isEnable: Bool { return true }

    public func getInfoFor(text: String, query: [String: Any]?) -> [String: String] {
        let model = WarrantFilterFormModel()
        if let query = query {
            model.params = query
            model.name = query["name"] as? String
            model.nickName = query["nickName"] as? String
            model.motherName = query["motherName"] as? String
            model.processNumber = query["proccessorNumber"] as? String
            model.state = query["dispatcherState"] as? String
            if let cityCode = query["dispatcherCity"] as? String,
            let city = CityDataSource().findByCode(cityCode) {
                model.city = city.name
            }
            model.documentType = query["documentType"] as? String
            model.documentNumber = query["documentNumber"] as? String
            return model.getInfo()
        }
        if text.matches(in: AppRegex.cpfPattern) {
            return ["CPF": text]
        }
        if text.matches(in: AppRegex.personNamePattern ) {
            return ["Nome": text.uppercased()]
        }
        return [:]
    }

    public func getParamsFor(text: String) -> [String: Any] {
        if let cpf = WarrantDocumentService().getDocuments().filter({$0.name.elementsEqual("CPF")}).first {
            if text.matches(in: AppRegex.cpfPattern) {
                return [
                    "documentType": "\(cpf.id)",
                    "documentNumber": text
                ]
            }
        }
        return ["name": text]
    }
}
