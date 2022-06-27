//
//  Roles.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 13/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct Roles {

    public static let notifyOcurrency = "ROLE_AGENTE_CAMPO_NOTIFICAR_OCORRENCIA"
    public static let notifyOcurrencyUpdate = "ROLE_AGENTE_CAMPO_NOTIFICAR_OCORRENCIA_ATUALIZACAO"
    public static let nofityOperationalPause = "ROLE_AGENTE_CAMPO_NOTIFICAR_PAUSA_OPERACIONAL"

    /// Permisão para poder pegar as últimas localizações do veículo quando possui alerta
    public static let vehicleTrack = "RL_AGC_BUSCA_VEICULO_RASTRO"

    /// Permite o uso do módulo de Mandadados de prisão (Banco Nacional de Mandados de Prisão)
    public static let searchBNMP = "RL_AGC_BUSCA_BNMP"

    /// Permite o uso do módulo de Veículos
    public static let searchVehicle = "RL_AGC_BUSCA_VEICULO"

    /// Permite ver o endereço nos detalhes de veículos
    public static let vehicleAddrees = "RL_AGC_BUSCA_VEICULO_ENDERECO"

    /// Permissão para poder acessar o módulo da API
    public static let agenteBuscaBO = "RL_AGC_BUSCA_BO"

    /// Permissão para poder retornar o texto do relato do BO
    public static let visualizarRelato =  "RL_AGC_BO_RELATO_VISUALIZAR"

    /// Permissão para poder acessar envolvimentos do tipo suposto autor/infrator
    /// O filtro do eixo de envolvidos deve apenas possibilitar o acesso de acordo com as permissões de tipos de envolvimento que o usuário possui, nesse caso, apenas suposto autores/infratores
    /// A mesma coisa deve ser levada em consideração na hora de listar os envolvimentos de um BO, apenas retorna de acordo com os tipos que o usuário pode acessar, nesse caso, apenas suposto autores/infratores
    public static let visualizarEnvolvidos = "RL_AGC_BO_SAI_VISUALIZAR"

    /// Permissão para poder acessar o endereço dos envolvidos
    /// Caso o usuário não a possua devemos retornar apenas a UF e município
    public static let visualizarEnderecosEnvolvidos = "RL_AGC_BO_ENVOLVIDO_ENDERECO"

    public static let searchDriver = "RL_AGC_BUSCA_CONDUTORES"

    public static let searchDriverAddress = "RL_AGC_BUSCA_CONDUTORES_END"

}
