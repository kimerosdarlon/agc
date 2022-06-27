//
//  TeamFormDelegate.swift
//  CAD
//
//  Created by Ramires Moreira on 10/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

protocol TeamFormDelegate: class {
    func newScheduled(_ team: Team)
    func newTemplate(_ team: Team)
}

extension TeamFormDelegate {

    func newScheduled(_ team: Team) {
        fatalError("not implemented")
    }

    func newTemplate(_ team: Team) {
        fatalError("not implemented")
    }
}
