//
//  FormViewControllerDelegate.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 11/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public protocol FormViewControllerDelegate: class {

    func didClickOnRightButton()

    func didClickOnLeftButton()
}

public extension FormViewControllerDelegate {

    func didClickOnRightButton() { }

    func didClickOnLeftButton() { }
}
