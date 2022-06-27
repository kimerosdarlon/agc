//
//  UserLocationAnnotation.swift
//  CAD
//
//  Created by Samir Chaves on 07/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class UserLocationAnnotationView: MKAnnotationView {
    static let identifier = "UserLocationAnnotation"
    private static let pinSize: CGFloat = 18

    let heading: MapUserHeadingView = {
        let pinSize: CGFloat = UserLocationAnnotationView.pinSize
        let heading = MapUserHeadingView(frame: .init(x: -3 - pinSize / 2, y: -27 - pinSize / 2, width: 25, height: 30))
        let rotation = CGFloat(45 / 180 * Double.pi) // 45º
        heading.transform = CGAffineTransform.identity.rotated(by: rotation)
        return heading
    }()

    private let pin: UIView = {
        let pinSize: CGFloat = UserLocationAnnotationView.pinSize
        let view = UIView(frame: .init(x: -pinSize / 2, y: -pinSize / 2, width: pinSize, height: pinSize))
        view.layer.cornerRadius = pinSize / 2
        view.layer.borderWidth = 2
        view.backgroundColor = .appBlue
        view.layer.borderColor = UIColor.white.cgColor.copy(alpha: 0.4)
        return view
    }()

    override func didMoveToSuperview() {
        addSubview(heading)
        addSubview(pin)
        collisionMode = .circle
    }

    override var annotation: MKAnnotation? {
        willSet {
            guard newValue is MKUserLocation else { return }
            image = nil
            canShowCallout = false
            backgroundColor = .white
        }
    }
}
