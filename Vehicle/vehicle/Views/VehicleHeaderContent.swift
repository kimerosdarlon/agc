//
//  VehicleHeaderContent.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class VehicleHeaderContent: UIView {

    let vehicleInfo: VehicleDetailHeaderCollectionView = {
        let collection = VehicleDetailHeaderCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.enableAutoLayout()
        return collection
    }()

    init(frame: CGRect, cornerRadius: CGFloat, details: VehicleDetailViewModel) {
        super.init(frame: frame)
        enableAutoLayout()
        backgroundColor = .appBackground
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        vehicleInfo.data =  details.getDetails()
        vehicleInfo.headers = details.headers
        vehicleInfo.lastUpdate = details.lastUpdate
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(vehicleInfo)
        NSLayoutConstraint.activate([
            vehicleInfo.topAnchor.constraint(equalTo: topAnchor),
            vehicleInfo.leadingAnchor.constraint(equalTo: leadingAnchor),
            vehicleInfo.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomAnchor.constraint(equalToSystemSpacingBelow: vehicleInfo.bottomAnchor, multiplier: 4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
