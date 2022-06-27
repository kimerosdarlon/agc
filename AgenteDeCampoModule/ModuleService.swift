//
//  ModuleService.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import Logger

public struct ModuleService {

    private static var modulos = [Module]()

    public static func register(module: Module) {
        if module.isEnable {
            ModuleService.modulos.append(module)
        }
    }

    public static func allWithRoles(_ roles: [String]?) -> [Module] {
        guard let roles = roles else { return [] }
        return modulos.filter { module in
            if let role = module.role {
                return roles.contains(role)
            } else {
                return true
            }
        }
    }

    public static func getController(for moduleName: String, search text: String, query: [String: Any]? ) -> SearchApiResultController? {
        guard let module = modulos.filter({$0.name == moduleName}).first else { return nil }
        var queryToUse = [String: Any]()
        if query != nil && !query!.isEmpty {
            queryToUse = query!
        } else {
            queryToUse = module.getParamsFor(text: text)
        }
        let query = queryToUse
        return module.controller.init(
            search: query,
            userInfo: module.getInfoFor(text: text, query: query),
            isFromSearch: true
        )
    }

    public static func showOptionsFor(value: String?) {
        let logger = Logger.forClass(Self.self)
        logger.debug("Mostrando valores para \(value ?? "")")
    }

    public static func clearAll() {
        modulos.removeAll()
    }
}
