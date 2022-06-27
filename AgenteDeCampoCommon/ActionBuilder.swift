//
//  ActionBuilder.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 24/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
import SPAlert
import Logger

public class ActionBuilder: NSObject {

    private let text: String
    private let hasMapInteraction: Bool
//    public var previewProvider: UIContextMenuContentPreviewProvider?
    private var modulesName: [String]
    private lazy var logger = Logger.forClass(Self.self)

    public init(text: String, hasMapInteraction: Bool = false, exceptedModuleNames modulesName: [String] = [] ) {
        self.text = text
        self.modulesName = modulesName
        self.hasMapInteraction = hasMapInteraction
        super.init()
    }

    public func createContextMenu() -> UIMenu {

        var actions: [UIMenuElement] = [ buildCopyAction(for: text) ]

        if let callAction = buildCallAction(for: text) {
            actions.append(callAction)
        }

        if let mapAction = buildMapAction(for: text), hasMapInteraction {
            actions.append(mapAction)
        }

        if let googlemMapAction = buildGoogleMapAction(for: text), hasMapInteraction {
            actions.append(googlemMapAction)
        }

        let user = UserService.shared.getCurrentUser()
        let modules = ModuleService.allWithRoles(user?.roles)
        var searchActions = [UIAction]()
        for module in modules {
            let moduleActions = module.getActionsFor(text: text, exceptedModuleNames: modulesName)
            searchActions.append(contentsOf: moduleActions)
        }

        let menuSearchAction = UIMenu(title: "", options: .displayInline, children: searchActions)
        actions.append(menuSearchAction)
        return UIMenu(title: "Opções", children: actions )
    }

    /// Cria uma ação de ligação
    /// - Parameter text: O número do telefone
    /// - Returns: a ação de ligar para um telefone
    private func buildCallAction(for text: String) -> UIAction? {
        if !text.matches(in: AppRegex.phonePattern) { return nil }
        guard let phoneURL = URL(string: "tel://+55\(text.onlyNumbers())") else { return nil }
        if !UIApplication.shared.canOpenURL(phoneURL) { return nil }
        let callImage = UIImage(systemName: "phone.fill")
        let callAction = UIAction(title: "Ligar", image: callImage) { _  in
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
        return callAction
    }

    /// Cria uma ação de copiar
    /// - Parameter text: o texto a ser copiado
    /// - Returns: a ação de copiar o texto
    private func buildCopyAction(for text: String) -> UIAction {
        let copyImage = UIImage(systemName: "doc.on.doc.fill")
        let copyAction = UIAction(title: "Copiar", image: copyImage) { _  in
            UIPasteboard.general.string = text
            SPAlert.present(title: "Tudo pronto",
                            message: "O texto \(text) foi copiado para a sua área de tranferência",
                            preset: .done)
        }
        return copyAction
    }

    private func buildMapAction(for text: String ) -> UIAction? {
        let searchParam = URLQueryItem(name: "q", value: text)
        var url = URLComponents(string: "https://waze.com/ul")
        url?.queryItems = [searchParam]
        let wazeUrl = URL(string: "waze://")!
        if let url = url?.url, UIApplication.shared.canOpenURL(wazeUrl) {
            let mapAction = UIAction(title: "Navegar com waze", image: UIImage(systemName: "car.fill")) { (_) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return mapAction
        }
        return nil
    }

    private func buildGoogleMapAction(for text: String ) -> UIAction? {
        let apiParam = URLQueryItem(name: "api", value: "1")
        let searchParam = URLQueryItem(name: "query", value: text)
        var url = URLComponents(string: "https://www.google.com/maps/search/")
        url?.queryItems = [apiParam, searchParam]
        let googleUrl = URL.init(string: "comgooglemaps://")!
        if let url = url?.url, UIApplication.shared.canOpenURL(googleUrl) {
            let mapAction = UIAction(title: "Navegar com Maps", image: UIImage(systemName: "car.fill")) { (_) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return mapAction
        }
        return nil
    }

}

extension ActionBuilder: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
//            let feedback = UISelectionFeedbackGenerator()
//            feedback.prepare()
//            feedback.selectionChanged()
            return self.createContextMenu()
        }
    }
}
