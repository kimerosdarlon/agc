//
//  VehicleCellViewModel.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 28/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct VehicleCellViewModel {

    var title: String {
        return vehicle.model ?? ""
    }

    var subtitle: String {
        return "\(vehicle.color ?? "" ) - \(vehicle.getYears())"
    }

    var hasAlert: Bool {
        let alerts = vehicle.alerts?.count ?? 0
        return alerts > 0
    }

    var plate: String {
        return vehicle.plate ?? ""
    }

    let vehicle: Vehicle

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }
}
