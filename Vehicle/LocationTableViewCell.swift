//
//  LocationTableViewCell.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 19/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    private var view: PinDetail!

    func configure(with location: VehicleLocation) {
        view = PinDetail(location: location)
        contentView.addSubview(view)
        view.enableAutoLayout()
        view.fillSuperView(regardSafeArea: true)
        backgroundColor = view.backgroundColor
        layer.masksToBounds = true
        view.layer.masksToBounds = true
        selectionStyle = .none
    }

    override func prepareForReuse() {
        contentView.subviews.first?.removeFromSuperview()
    }

    func setBackground(color: UIColor) {
        backgroundColor = color
        if let view = view {
            view.backgroundColor = color
        }
    }

    func setPosition(_ position: Int) {
        if let view = view {
            view.setPosition(position)
        }
    }
}
