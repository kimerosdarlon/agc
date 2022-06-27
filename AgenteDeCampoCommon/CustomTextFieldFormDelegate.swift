//
//  CustomTextFieldFormDelegate.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

@objc public protocol CustomTextFieldFormDelegate: class {
    @objc optional func didClickEnter(_ textFiled: UITextField)
    @objc optional func didBeginEdite(_ textFiled: UITextField)
}
