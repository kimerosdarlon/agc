//
//  CheckboxDelegate.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 13/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation

public protocol CheckboxDelegate: class {
    func didChanged(checkbox: Checkbox)
}
