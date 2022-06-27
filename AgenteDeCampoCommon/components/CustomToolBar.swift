//
//  CustomToolBar.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 16/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class CustomToolBar: UIToolbar {
    private let customHeight: CGFloat = 50
    public var state: ToobarState = .hidden

    public override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        let space: CGFloat = bounds.size.height > 800 ? 40 : 0
        let yPosition = state == .hidden ?  bounds.size.height : bounds.size.height - customHeight - space
        self.frame = CGRect(x: 0, y: yPosition, width: bounds.width, height: customHeight)
    }
}

public enum ToobarState {
    case hidden
    case visible
}
