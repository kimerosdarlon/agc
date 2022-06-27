//
//  SentenceViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class SentenceViewController: GenericViewController {

    private let synthesis: String?

    init(sentence: Sentence) {
        synthesis = sentence.synthesis
        super.init(data: [[
            ItemDetail(title: "Magistrado(a)", detail: sentence.magistrate, colunms: 3),
            ItemDetail(title: "Síntese", detail: sentence.synthesis, colunms: 3)
        ]], title: "Sentença")
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

//    override func contentHeight() -> CGFloat {
//        let width = view.frame.width * 0.85
//        let attr = [NSAttributedString.Key.font: UIFont.robotoRegular.withSize(13)]
//        let title = NSString(string: synthesis )
//        let size = CGSize(width: width, height: 1000)
//        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
//        return estimateFrame.height + 100
//    }

}
