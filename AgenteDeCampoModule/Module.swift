//
//  Module.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import Logger
import UIKit

public protocol Module {

    /// Nome do módulo, este é o nome que aparece na collection que fica na tela de Home
    var name: String { get }

    /// Um array com os patterns que o módulo aceita. Ex placa ["^[a-zA-Z]{3}\\D{0,3}\\d{4}$", "^[a-zA-Z]{3}\\D{0,3}\\d\\w\\d{2}$"]
    var patterns: [String] { get }

    /// O nome da imagem queirá aparecer na tela de home. A imagem deve está no Assets
    var imageName: String { get }

    /// Permissão necessária para acessar o módulo. Caso seja nula, nenhuma permissão é necessário ou a permissão é gerenciada com outra estratégia.
    var role: String? { get }

    /// O Controller que deve ser apresentado quando o item da search for selecionado
    var controller: SearchApiResultController.Type { get }

    /// O controller que é deve ser apresentado quando um item da collection for selecionado
    var filterController: ModuleFilterViewControllerProtocol.Type? { get }

    /// Você pode usar essa flag para desabilitar o módulo quando este ainda está em desenvolvimento, utilize a classe FeatureFlag para isso
    var isEnable: Bool { get }

    /// Deve retornar o dicionário de parâmetros de busca no servidor, dado um determinado texto de busca
    /// - Parameter text: O texto em que o usuário digitou na search bar
    func getParamsFor(text: String) -> [String: Any]

    /// Retorna as informações que serão mostradas na parte superior da tela de filtros. Esse método é invocado em dois momentos distintos.
    /// Sendo um quando o o usuário faz a busca na search ou na tela de filtros e o outro quando o usuário seleciona algum item do histórico
    /// - Parameters:
    ///   - text: O texto em que o usuário digitou na search bar
    ///   - query:
    func getInfoFor(text: String, query: [String: Any]?) -> [String: String]

    /// Retorna true se o texto passado casa com algum valor de regex retornado pelo `patterns`.
    /// Não é necessário implementar este método, a não ser que seja detectado alguma inconsistência na implementação.
    /// - Parameter text: texto digitado pelo usuário na search bar
    func matches(in text: String) -> Bool

    /// Retorna um array de ações que podem ser executadas em um context menu.
    /// - Parameters:
    ///   - text: Texto selecionado para executar a ação
    ///   - names: um array com os nomes dos módulos que devem desconsiderar a criação da ação.
    func getActionsFor(text: String, exceptedModuleNames names: [String] ) -> [UIAction]

}

public extension Module {

    /// Implementação padrão
    /// - Parameter text: string de para verificação
    /// - Returns: true se casar com algum pattern fornecido em `patterns`
    func matches(in text: String) -> Bool {
        let logger = Logger.forClass(Self.self)
        do {
            for pattern in patterns {
                let regex = try NSRegularExpression(pattern: pattern)
                let foldedText = text.prepareForSearch()
                let results = regex.matches(in: foldedText, range: NSRange(text.startIndex..., in: foldedText))
                if !results.isEmpty {
                    return true
                }
            }
            return false
        } catch let error {
            logger.debug("invalid regex: \(error.localizedDescription)")
            return false
        }
    }

    static func == (lhs: Module, rhs: Module) -> Bool {
        return lhs.name == rhs.name && lhs.patterns == rhs.patterns
    }
}
