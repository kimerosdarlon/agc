//
//  CirclePinAnnotation.swift
//  CAD
//
//  Created by Samir Chaves on 30/04/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class CirclePinAnnotation: MKPointAnnotation { }

class CirclePinAnnotationView: MKAnnotationView {
    static let identifier = "CirclePinAnnotation"

    override var annotation: MKAnnotation? {
        willSet {
            guard newValue is CirclePinAnnotation else { return }
            configure()
        }
    }

    func configure() {
        image = nil
        frame = .init(x: 0, y: 0, width: 10, height: 10)
        backgroundColor = UIColor.appTitle
        alpha = 0.8
        layer.cornerRadius = 5
        canShowCallout = false
    }
}
