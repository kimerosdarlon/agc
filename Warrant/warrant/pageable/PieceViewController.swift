//
//  PieceViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class PieceViewController: GenericViewController {

    public init(piece: Piece) {
        super.init(data: [[
            ItemDetail(title: "Nº da Peça", detail: piece.pieceNumber, colunms: 3),
            ItemDetail(title: "Processo", detail: piece.processNumber, colunms: 3),
            ItemDetail(title: "Situação", detail: piece.situation, colunms: 1.5),
            ItemDetail(title: "Data de validade", detail: piece.dateFormatted, colunms: 1.5),
            ItemDetail(title: "Tipo do mandado", detail: piece.type.name, colunms: 1.5)
        ]], title: "Peça")
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    public override func contentHeight() -> CGFloat {
        return 220
    }
}
