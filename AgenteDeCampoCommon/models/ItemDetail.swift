//
//  ItemDetail.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 12/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public struct ItemDetail {
    public let title: String
    public let detail: String?
    public let colunms: CGFloat
    public var hasInteraction = false
    public var detailBackGroundColor: UIColor?

    public init(title: String, detail: String?, colunms: CGFloat, hasInteraction: Bool = false, detailBackGroundColor: UIColor? = nil) {

        self.title = title
        self.detail = detail
        self.colunms = colunms
        self.hasInteraction = hasInteraction
        self.detailBackGroundColor = detailBackGroundColor

    }
}
