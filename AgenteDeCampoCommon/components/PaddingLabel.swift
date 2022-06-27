//
//  PaddingLabel.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 12/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

open class PaddingLabel: UILabel {

    public var topInset: CGFloat
    public var bottomInset: CGFloat
    public var leftInset: CGFloat
    public var rightInset: CGFloat

    public required init(withInsets top: CGFloat, _ bottom: CGFloat, _ left: CGFloat, _ right: CGFloat) {
        self.topInset = top
        self.bottomInset = bottom
        self.leftInset = left
        self.rightInset = right
        super.init(frame: CGRect.zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += topInset + bottomInset
        contentSize.width += leftInset + rightInset
        return contentSize
    }
}
