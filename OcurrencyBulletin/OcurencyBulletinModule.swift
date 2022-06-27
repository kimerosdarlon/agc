//
//  OcurencyBulletinModule.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 26/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoModule
import AgenteDeCampoCommon
import UIKit
import Logger
public class OcurencyBulletinModule: Module {

    public init() {}

    private lazy var logger = Logger.forClass(Self.self)

    public func getActionsFor(text: String, exceptedModuleNames names: [String]) -> [UIAction] {
        if names.contains(name) {
            return []
        }
        var actions = [UIAction]()
        let foldedText = text
        if foldedText.isCPF || foldedText.matches(inAny: AppRegex.platePatterns) ||
            foldedText.matches(in: AppRegex.chassiPattern ) || foldedText.matches(in: AppRegex.personNamePattern) {
            let action = searchActionFor(text: text)
            actions.append(action)
        }
        return actions
    }

    private func searchActionFor(text: String) -> UIAction {
        let params = getParamsFor(text: text)
        let controller = OcurrenceBulletinViewController(search: params, userInfo: getInfoFor(text: text, query: params), isFromSearch: false)
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

    public var name: String { "Boletins de ocorrência" }

    public var patterns: [String] {
        return AppRegex.platePatterns + [AppRegex.personNamePattern, AppRegex.cpfPattern, AppRegex.cnpjPattern, AppRegex.codeNationalPattern]
    }

    public var imageName: String { "bulletin" }

    public var role: String? { Roles.agenteBuscaBO }

    public var controller: SearchApiResultController.Type { OcurrenceBulletinViewController.self }

    public var filterController: ModuleFilterViewControllerProtocol.Type? { OccurrenceBulletinFilterViewController.self }

    public var isEnable: Bool { true }

    public func getParamsFor(text: String) -> [String: Any] {
        let nameResolver = PersonNameResolver(next: nil)
        let chassisResolver = ChassiResolver(next: nameResolver)
        let plateResolver = PlateResolver(next: chassisResolver)
        let codNacionalResolver = CodNacionalResolver(next: plateResolver)
        let cnpjResolver = CNPJResolver(next: codNacionalResolver)
        let cpfResolver = CPFResolver(next: cnpjResolver)
        return cpfResolver.resolveSearch(text: text)
    }

    public func getInfoFor(text: String, query: [String: Any]?) -> [String: String] {
        if let query = query as? [String: String] {
            let filter = OccurrenceBulletinFilterViewModel()
            filter.setValuesFromSearch(params: query)
            return filter.getInfos()
        }

        let nameResolver = PersonNameResolver(next: nil)
        let chassisResolver = ChassiResolver(next: nameResolver)
        let plateResolver = PlateResolver(next: chassisResolver)
        let codNacionalResolver = CodNacionalResolver(next: plateResolver)
        let cnpjResolver = CNPJResolver(next: codNacionalResolver)
        let cpfResolver = CPFResolver(next: cnpjResolver)
        return cpfResolver.resolveInfo(text: text)
    }
}

protocol SearchTextResolver {
    var next: SearchTextResolver? {get set}
    func resolveSearch(text: String) -> [String: Any]
    func resolveInfo(text: String) -> [String: String]
}
