//
//  Occurrence.swift
//  CAD
//
//  Created by Samir Chaves on 11/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import MapKit

class OccurrenceMapView: MKMapView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        enableAutoLayout()
        isRotateEnabled = true
        showsCompass = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
