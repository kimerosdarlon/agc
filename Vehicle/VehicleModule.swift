//
//  VehicleModule.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 26/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoModule
import AgenteDeCampoCommon
import UIKit

public class VehicleModule: Module {

    public init() {

    }

    public func getActionsFor(text: String, exceptedModuleNames names: [String]) -> [UIAction] {
        print(text)
        if names.contains(name) {
            return []
        }
        var actions = [UIAction]()
        if text.isCPF || text.matches(in: AppRegex.chassiPattern) || text.matches(inAny: AppRegex.platePatterns) {
            actions.append( searchActionFor(text: text) )
        }
        return actions
    }

    private func searchActionFor(text: String) -> UIAction {
        let params = getParamsFor(text: text)
        let controller = VehicleViewController(search: params, userInfo: getInfoFor(text: text, query: params), isFromSearch: false)
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

    public var name: String { "Veículos" }

    public var patterns: [String] {
        var patternes = AppRegex.platePatterns
        patternes.append(AppRegex.cpfPattern)
        patternes.append(AppRegex.chassiPattern)
        return patternes
    }

    public var imageName: String { "car" }

    public var role: String? { Roles.searchVehicle }

    public var controller: SearchApiResultController.Type { VehicleViewController.self }

    public var filterController: ModuleFilterViewControllerProtocol.Type? { VehicleFilterViewController.self }

    public var isEnable: Bool { true }

    public func getInfoFor(text: String, query: [String: Any]?) -> [String: String] {
        if text.isCPF {
            return ["CPF": text.onlyStandardCharacters().apply(pattern: AppMask.cpfMask, replacmentCharacter: "#")]
        } else if text.matches(in: AppRegex.chassiPattern) {
            return ["Chassis": text]
        }
        return ["Placa": text.uppercased().onlyStandardCharacters().apply(pattern: "###-####", replacmentCharacter: "#")]
    }

    public func getParamsFor(text: String ) -> [String: Any] {
        if text.isCPF {
            return ["type": "owner", "owner": text.onlyStandardCharacters()]
        } else if text.matches(in: AppRegex.chassiPattern) {
            return ["type": "chassis", "chassis": text]
        }
        return ["type": "plate", "plate": text.uppercased().onlyStandardCharacters()]
    }
}
