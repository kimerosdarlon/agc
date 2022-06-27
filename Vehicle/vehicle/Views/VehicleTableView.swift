//
//  VehicleTableView.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class VehicleTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        enableAutoLayout()
        let identifier = String(describing: LocationTableViewCell.self)
        register(LocationTableViewCell.self, forCellReuseIdentifier: identifier)
        backgroundColor = .appBackgroundCell
        tableFooterView = UIView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
