//
//  GenericSearchViewControllerDataSource.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 01/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public protocol GenericSearchViewControllerDataSource: UITableViewDataSource {
    func didReturnNotFoundConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?)
    func didReturnServerErrorConfiguration() -> (title: String, subtitle: String?, showButtonAction: Bool, buttonTitle: String?)
}
