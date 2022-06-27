//
//  OccurrenceIconProvider.swift
//  CAD
//
//  Created by Samir Chaves on 04/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

let iconsData = [
    "Resgate": "natResgate",
    "Jogo de Azar": "natJogoAzar",
    "Produto Perigoso": "natProdutoPerigoso",
    "Menor Vítima": "natMenorVitima",
    "Crimes Contra a Honra": "natCrimesContraHonra",
    "Transporte Coletivo": "natTransporteColetivo",
    "Trânsito": "natTransito",
    "Patrulhamento": "natPatrulhamento",
    "Táxi": "natTaxi",
    "Furto de Carga": "natFurtoCarga",
    "Velocidade": "natVelocidade",
    "Insetos": "natInsetos",
    "Alarme": "natAlarme",
    "Meio Ambiente": "natMeioAmbiente",
    "Guincho": "natGuincho",
    "Índio": "natIndio",
    "Deficiência": "natDeficiencia",
    "Fiscalização": "natFiscalizacao",
    "Grupo": "natGrupo",
    "Animal": "natAnimal",
    "Localização": "natLocalizacao",
    "Fraude": "natFraude",
    "Caça e Pesca": "natCacaPesca",
    "Vistoria": "natVistoria",
    "Estacionamento": "natEstacionamento",
    "Mandado de Prisão": "natMandadoPrisao",
    "Corte de Anel": "natCorteAnel",
    "Cadáver": "natCadaver",
    "Parto": "natParto",
    "CAD": "natCAD",
    "Eleitoral": "natEleitoral",
    "Abordagem Social": "natAbordagemSocial",
    "Atitude Suspeita": "natAtitudeSuspeita",
    "Desaparecimento de Pessoa": "natDesaparecimentoPessoa",
    "Semáforo": "natSemaforo",
    "Perigo": "natPerigo",
    "Bomba": "natBomba",
    "Saúde": "natSaude",
    "Impedimento": "natImpedimento",
    "Suicídio": "natSuicidio",
    "Violação": "natViolacao",
    "Estupro": "natEstupro",
    "Denúncia": "natDenuncia",
    "Embriaguez": "natEmbriaguez",
    "Prisão": "natPrisao",
    "Sequestro": "natSequestro",
    "ECA": "natECA",
    "Arma": "natArma",
    "Roubo": "natRoubo",
    "Arma Não Letal": "natArmaNaoLetal",
    "Morte": "natMorte",
    "Arma Branca": "natArmaBranca",
    "Lesão": "natLesao",
    "Omissão": "natOmissao",
    "Vulnerável": "natVulneravel",
    "Maus Tratos - Animal": "natMausTratosAnimal",
    "Maus Tratos Animal Silvestre": "natMausTratosAnimalSilvestre",
    "Maus Tratos - Pessoa": "natMausTratosPessoa",
    "Violação de Domicílio": "natViolacaoDomicilio",
    "Idoso": "natIdoso",
    "Omissão de Cautela": "natOmissaoCautela",
    "Perturbação": "natPerturbacao",
    "Acidente": "natAcidente",
    "Eletricidade": "natEletricidade",
    "Desastres": "natDesastres",
    "Animal Peçonhento": "natAnimalPeconhento",
    "Drogas": "natDrogas",
    "Averiguação": "natAveriguacao",
    "Agressão": "natAgressao",
    "Furto": "natFurto",
    "Perícia": "natPericia",
    "Violência Doméstica": "natViolenciaDomestica",
    "Incêndio": "natIncendio"
]

class OccurrenceIconProvider {
    static var shared = OccurrenceIconProvider()

    @domainServiceInject
    private var domainService: DomainService

    func getIcon(for nature: String) -> UIImage? {
        let natureGroup = domainService.getGroupByNature(nature)
        if let groupIcon = natureGroup.flatMap({ iconsData[$0] }) {
            return UIImage(named: groupIcon)?.withRenderingMode(.alwaysOriginal)
        } else {
            return UIImage(named: "natPadrao")?.withRenderingMode(.alwaysOriginal)
        }
    }
}
