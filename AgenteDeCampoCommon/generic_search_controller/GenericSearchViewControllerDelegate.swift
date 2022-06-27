//
//  GenericSearchViewControllerDelegate.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 01/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public protocol GenericSearchViewControllerDelegate: UITableViewDelegate {
    func didClickRetryButton(_ button: UIButton, on state: GenericSearchViewConrtollerState)
    func didClickOnFilterButton()
}
