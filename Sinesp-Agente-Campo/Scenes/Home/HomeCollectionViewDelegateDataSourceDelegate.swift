//
//  HomeCollectionViewDelegateDataSourceDelegate.swift
//  RestClient
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule

protocol HomeCollectionViewDelegateDataSourceDelegate: class {
    func present(viewController: ModuleFilterViewControllerProtocol)
    func show(_ message: String)
}
