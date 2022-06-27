//
//  VehicleMapView.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import MapKit

class VehicleMapView: MKMapView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        enableAutoLayout()
        register(CustomPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
        isRotateEnabled = true
        showsCompass = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
