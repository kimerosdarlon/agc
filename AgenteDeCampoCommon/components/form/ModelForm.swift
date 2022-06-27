//
//  ModelForm.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 11/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public protocol ModelForm {
    associatedtype Entity
    func set(value: String?, path: ReferenceWritableKeyPath<Entity, String?>)
}
