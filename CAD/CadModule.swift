//
//  CadModule.swift
//  CAD
//
//  Created by Ramires Moreira on 04/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
import AgenteDeCampoModule

public class CadModule: Module {

    public init() {}

    public var name: String { "CAD Ocorrências" }

    public var patterns: [String] {
        return [AppRegex.cpfPattern] + AppRegex.platePatterns
    }

    public var imageName: String { "cad" }

    public var role: String? { nil }

    public var controller: SearchApiResultController.Type { OccurrencesViewController.self }

    public var filterController: ModuleFilterViewControllerProtocol.Type? { CadFilterViewController.self }

    public var isEnable: Bool { FeatureFlags.cadOccurrencesModule }

    public func getParamsFor(text: String) -> [String: Any] {
        if text.isCPF {
            let value = text.onlyNumbers()
            return [
                "involvedCPF": ["serviceValue": value, "userValue": value]
            ]
        } else if text.matches(inAny: AppRegex.platePatterns) {
            let value = text.onlyStandardCharacters().lowercased()
            return [
                "vehiclePlate": ["serviceValue": value, "userValue": value]
            ]
        }
        return [:]
    }

    public func getInfoFor(text: String, query: [String: Any]?) -> [String: String] {
        if let anyQuery = query, let cadQuery = anyQuery as? [String: CadFilterSearchField] {
            var params = [String: String]()
            for (key, value) in cadQuery where value["userValue"] != nil {
                if let userValue = value["userValue"]! {
                    params[key] = userValue as? String
                }
            }
            let info = CadFilterViewModel.getInfo(from: params)
            return info
        }

        return [:]
    }

    public func getActionsFor(text: String, exceptedModuleNames names: [String]) -> [UIAction] {
        if names.contains(name) {
            return []
        }
        var actions = [UIAction]()

        let foldedText = text.prepareForSearch()
        if foldedText.isCPF || foldedText.matches(inAny: AppRegex.platePatterns) {
            let action = searchActionFor(text: text)
            actions.append(action)
        }
        return actions
    }

    private func searchActionFor(text: String) -> UIAction {
        let params = getParamsFor(text: text)
        let controller = OccurrencesViewController(search: params, userInfo: getInfoFor(text: text, query: params), isFromSearch: false)
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

}
