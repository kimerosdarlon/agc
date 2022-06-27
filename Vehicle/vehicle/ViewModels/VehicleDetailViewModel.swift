//
//  VehicleDetailViewModel.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 01/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import Logger

struct ItemDetail {
    let title: String
    let detail: String?
    let colunms: CGFloat
    var hasInteraction = false
    var hasMapInteraction = false
    var detailBackGroundColor: UIColor?
}

struct VehicleDetailViewModel {
    private let vehicle: Vehicle
    private(set) var headers = [String]()
    private lazy var logger = Logger.forClass(Self.self)
    var lastUpdate: String {
        let falbackString = "Atualizado em: ---"
        guard let lastUpdate = vehicle.characteristicsLastUpdate else { return falbackString }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: lastUpdate) else { return falbackString }
        formatter.dateFormat = "'Atualizado em:' dd/MM/yyyy"
        return formatter.string(from: date)
    }

    var alert: VehicleAlert? {
        return vehicle.alerts?.first
    }

    var hasAlert: Bool { vehicle.hasAlert }
    var alertSystemOutOfService: Bool { vehicle.alertSystemOutOfService }

    var plate: String {
        return vehicle.plate ?? ""
    }

    var title: String {
        let model = vehicle.model ?? ""
        let color = vehicle.color ?? ""
        return "\(model) | \(color)"
    }

    var cargaMaxima: String {
        if let traction = vehicle.mechanics?.tractionKg, traction > 0 {
            return "\(traction/1000)"
        }
        return "---"
    }

    var capacidadeMaxima: String {
        if let charge = vehicle.capacity?.chargeKg, charge > 0 {
            return "\(charge/1000)"
        }
        return "---"
    }

    var conversionAlert: String? {
        return vehicle.conversionAlert
    }

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        let ownerName = vehicle.owner?.name ?? ""
        let possessorName = vehicle.possessor?.name ?? ""
        let showPossessor = !ownerName.elementsEqual(possessorName)
        if showPossessor {
            self.headers = ["Dados do Veículo", "Proprietário",
                            "Possuidor", "Dados complementares do Veículo",
                            "Emplacamento", "Dados de importação"]
        } else {
            self.headers = ["Dados do Veículo", "Proprietário/Possuidor",
                            "Dados complementares do Veículo",
                            "Emplacamento", "Dados de importação"]
        }

        if let address = vehicle.owner?.address ?? vehicle.possessor?.address {
            logger.debug("Veículo possui endereço \(address)")
        } else {
            logger.debug("Veículo não possui endereço")
        }
    }

    fileprivate func vehichle() -> [ItemDetail] {
        var state = ""
        if let str = vehicle.licensePlate?.state {
            state = "/\(str)"
        }
        let city = vehicle.city ?? ""
        return [
            ItemDetail(title: "Ano", detail: vehicle.getYears(), colunms: 1.5),
            ItemDetail(title: "Cidade/UF", detail: "\(city)\(state)", colunms: 1.5),

            ItemDetail(title: "Combustível", detail: vehicle.fuelType, colunms: 1.5),
            ItemDetail(title: "Restrições Administrativas", detail: vehicle.restriction, colunms: 1.5),

            ItemDetail(title: "Chassi", detail: vehicle.chassis, colunms: 1.5, hasInteraction: true),
            ItemDetail(title: "Chassi Remarcado", detail: vehicle.remarcado, colunms: 1.5),

            ItemDetail(title: "Renavam", detail: vehicle.renavam, colunms: 1.5),
            ItemDetail(title: "Tipo Carroceria", detail: vehicle.bodyworkType, colunms: 1.5),

            ItemDetail(title: "Espécie", detail: vehicle.specie, colunms: 1.5),
            ItemDetail(title: "Tipo de veículo", detail: vehicle.type, colunms: 1.5)
        ]
    }

    fileprivate func owner() -> [ItemDetail] {
        let owner = vehicle.owner
        let documentNumber = owner?.document?.number.applyCpfORCnpjMask
        let documentType = owner?.document?.type ?? "Não informado"

        var infos = [
            ItemDetail(title: "Nome", detail: owner?.name, colunms: 1.5, hasInteraction: true),
            ItemDetail(title: documentType, detail: documentNumber, colunms: 1.5, hasInteraction: true)
        ]

        if let address = owner?.address {
            let item = ItemDetail(title: "Endereço", detail: address, colunms: 3, hasInteraction: true,
                                  hasMapInteraction: true)
            infos.append(item)
        }

        return infos
    }

    fileprivate func possessor() -> [ItemDetail] {
        let owner = vehicle.possessor
        let possessorDocumentNumber = owner?.document?.number.applyCpfORCnpjMask
        let documentType = owner?.document?.type ?? "Não informado"

        var infos = [
            ItemDetail(title: "Nome", detail: owner?.name, colunms: 1.5, hasInteraction: true),
            ItemDetail(title: documentType, detail: possessorDocumentNumber, colunms: 1.5, hasInteraction: true)
        ]

        if let address = owner?.address {
            let item = ItemDetail(title: "Endereço", detail: address, colunms: 3, hasInteraction: true,
                                  hasMapInteraction: true)
            infos.append(item)
        }

        return infos
    }

    fileprivate func licensePlate() -> [ItemDetail] {
        let licensePlateDocumentNumber = vehicle.billing?.document.number.applyCpfORCnpjMask
        let document = vehicle.billing?.document.type ?? "Doc."
        return [
            ItemDetail(title: "Estado", detail: vehicle.licensePlate?.state, colunms: 1.5),
            ItemDetail(title: "Data de emplacamento", detail: vehicle.licensePlate?.dateFormatted, colunms: 1.5),

            ItemDetail(title: "\(document) de faturamento ", detail: licensePlateDocumentNumber, colunms: 1.5),
            ItemDetail(title: "UF do Faturamento", detail: vehicle.billing?.state, colunms: 1.5)
        ]
    }

    fileprivate func vehicleComplementaryInfos() -> [ItemDetail] {
        let motor = vehicle.identifiers?.motor ?? "---"
        let cambio = vehicle.identifiers?.gearbox ?? "---"
        return [
            ItemDetail(title: "Peso Bruto(T)", detail: vehicle.totalGrossWeight, colunms: 1.5),
            ItemDetail(title: "Carga Máxima de Tração (T)", detail: cargaMaxima, colunms: 1.5),

            ItemDetail(title: "Capacidade Máxima de Carga (T)", detail: capacidadeMaxima, colunms: 1.5),
            ItemDetail(title: "Motor", detail: motor, colunms: 1.5, hasInteraction: motor != "---" ),

            ItemDetail(title: "Passageiros", detail: vehicle.passengers, colunms: 1.5),
            ItemDetail(title: "Nº da Carroceiria", detail: vehicle.identifiers?.bodywork, colunms: 1.5),

            ItemDetail(title: "Nº da caixa de câmbio", detail: cambio, colunms: 1.5, hasInteraction: cambio != "---" ),
            ItemDetail(title: "Qtd. de Eixos", detail: "\(vehicle.mechanics?.axleQuantity ?? 0)", colunms: 1.5),

            ItemDetail(title: "Nº Eixo traseiro", detail: vehicle.identifiers?.rearAxle, colunms: 1.5),
            ItemDetail(title: "Nº Eixo auxiliar", detail: vehicle.identifiers?.auxiliaryShaft, colunms: 1.5),

            ItemDetail(title: "Tipo de Montagem", detail: vehicle.mountingType, colunms: 1.5),
            ItemDetail(title: "Potência (HP)", detail: "\(vehicle.mechanics?.potencyHp ?? 0)", colunms: 1.5),

            ItemDetail(title: "Cilindradas", detail: "\(vehicle.mechanics?.engineCapacity ?? 0)", colunms: 1.5)
        ]
    }

    fileprivate func vehicheImport() -> [ItemDetail] {
        return [ // importação
            ItemDetail(title: "Identificador do Importador", detail: vehicle.vehicleImport?.importerId, colunms: 1.5),
            ItemDetail(title: "Identificador da declaração", detail: vehicle.vehicleImport?.declarationId, colunms: 1.5)
        ]
    }

    func getDetails() -> [[ItemDetail]] {
        let ownerName = vehicle.owner?.name ?? ""
        let possessorName = vehicle.possessor?.name ?? ""
        let showPossessor = !ownerName.elementsEqual(possessorName)
        var infos = [ vehichle() ]
        infos.append( owner() )
        if showPossessor {
            infos.append(possessor())
        }
        infos.append(contentsOf: [ vehicleComplementaryInfos(), licensePlate(), vehicheImport()])
        return infos
    }
}
