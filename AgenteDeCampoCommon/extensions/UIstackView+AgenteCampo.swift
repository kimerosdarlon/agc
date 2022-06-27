//
//  UIstackView+AgenteCampo.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 04/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public extension UIStackView {

    @discardableResult
    func addArrangedSubviewList( views: UIView?...) -> Self {
        views.filter({$0 != nil }).forEach({ self.addArrangedSubview($0!) })
        return self
    }

    @discardableResult
    func addArrangedSubviewIf( _ test: Bool, _ view: UIView) -> Self {
        if test {
            addArrangedSubview(view)
        }
        return self
    }

    @discardableResult
    func addArrangedSubviewList( views: [UIView] ) -> Self {
        views.forEach({ self.addArrangedSubview($0) })
        return self
    }

    func addGesture(_ gesture: UIGestureRecognizer) -> Self {
        addGestureRecognizer(gesture)
        return self
    }
}
