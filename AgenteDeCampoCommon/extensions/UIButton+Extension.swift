//
//  UIButton+Extension.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 01/09/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

@objc class ClosureSleeve: NSObject {
    let closure: () -> Void

    init (_ closure: @escaping () -> Void ) {
        self.closure = closure
    }

    @objc func invoke () {
        closure()
    }
}

public extension UIButton {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, "[\(arc4random())]", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
