//
//  VehicleContraintsConfigurations.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class VehicleContraintsConfigurations {

    func setupContraints(controller: VehicleDetailViewController ) {
        let safeArea = controller.view.safeAreaLayoutGuide
        controller.alertView.enableAutoLayout()
        let vehicleDetail = controller.vehicleDetail
        let height: CGFloat = (vehicleDetail.hasAlert || vehicleDetail.alertSystemOutOfService) ? controller.alertHeightColapsed : 0
        controller.alertHeightConstraint = controller.alertView.heightAnchor.constraint(equalToConstant: height)
        controller.alertHeightConstraint.isActive = true
        controller.locationDetailViewHeight = controller.locationDetailView.heightAnchor.constraint(equalToConstant: controller.defaultFooterHeight)
        controller.plateView.setFontStyle(.large)
        NSLayoutConstraint.activate([
            controller.alertView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1),
            controller.alertView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            controller.alertView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),

            controller.plateView.topAnchor.constraint(equalToSystemSpacingBelow: controller.alertView.bottomAnchor, multiplier: 1),
            controller.plateView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            controller.plateView.heightAnchor.constraint(equalToConstant: 80),
            controller.plateView.widthAnchor.constraint(equalTo: safeArea.widthAnchor),

            controller.vehicleContentView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            controller.vehicleContentView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            controller.vehicleContentView.topAnchor.constraint(equalToSystemSpacingBelow: controller.plateView.bottomAnchor, multiplier: 1),
            controller.headerViewInterector.leadingAnchor.constraint(equalTo: controller.vehicleContentView.leadingAnchor),
            controller.headerViewInterector.trailingAnchor.constraint(equalTo: controller.vehicleContentView.trailingAnchor),
            controller.headerViewInterector.bottomAnchor.constraint(equalTo: controller.vehicleContentView.bottomAnchor),
            controller.headerViewInterector.heightAnchor.constraint(equalToConstant: 40),

            controller.locationDetailView.widthAnchor.constraint(equalTo: controller.view.widthAnchor),
            controller.locationDetailView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            controller.locationDetailView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            controller.locationDetailViewHeight
        ])

        mapConstraints(controller: controller)
    }

    func mapConstraints(controller: VehicleDetailViewController) {
        if controller.canSeeVehiclesTrack {
            NSLayoutConstraint.activate([
                controller.vehicleMapView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
                controller.vehicleContentView.bottomAnchor.constraint(equalToSystemSpacingBelow: controller.vehicleMapView.topAnchor, multiplier: 5),
                controller.vehicleMapView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
                controller.vehicleMapView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
                controller.switchMapListButton.topAnchor.constraint(equalToSystemSpacingBelow: controller.vehicleContentView.bottomAnchor, multiplier: 2),
                controller.switchMapListButton.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
                controller.tableViewVehicleLocations.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
                controller.tableViewVehicleLocations.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
                controller.tableViewVehicleLocations.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }
}
