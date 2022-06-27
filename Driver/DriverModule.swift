//
//  DriverModule.swift
//  SinespAgenteCampo
//
//  Created by Samir Chaves on 13/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon
import CoreDataModels

public class DriverModule: Module {

    public init() {}

    public func getParamsFor(text: String) -> [String: Any] {
        if text.isCPF {
            return ["cpf": text]
        }

        return ["cnh": text]
    }

    public func getActionsFor(text: String, exceptedModuleNames names: [String]) -> [UIAction] {

        if names.contains(name) {
            return []
        }

        var actions = [UIAction]()
        if text.isCPF {
            actions.append(searchActionFor(text: text))
        }
        return actions
    }

    private func searchActionFor(text: String) -> UIAction {
        let params = getParamsFor(text: text)
        let controller = DriverViewController(search: params, userInfo: getInfoFor(text: text, query: params), isFromSearch: false)
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

    public var name: String { "Condutores" }

    public var patterns: [String] {
        return [AppRegex.cpfPattern, AppRegex.cnhPattern]
    }

    public var imageName: String { "cnh" }

    public var role: String? {
        Roles.searchDriver
    }

    public var controller: SearchApiResultController.Type {
        DriverViewController.self
    }

    public var filterController: ModuleFilterViewControllerProtocol.Type? {
        DriverFilterViewController.self
    }

    public var isEnable: Bool { return true }

    public func getInfoFor(text: String, query: [String: Any]?) -> [String: String] {
        let model = DriverFilterFormModel()

        if let query = query {
            model.params = query
            model.cpf = query["cpf"] as? String
            model.cnh = query["cnh"] as? String
            model.renach = query["renach"] as? String
            model.pid = query["pid"] as? String
            return model.getInfo()
        }

        if text.matches(in: AppRegex.cpfPattern) {
            return ["cpf": text]
        }

        return [:]
    }
}
