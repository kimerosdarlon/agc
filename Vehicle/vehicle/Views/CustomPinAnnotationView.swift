//
//  CustomPinAnnotationView.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import MapKit

class CustomPinAnnotationView: MKPinAnnotationView {
    var location: VehicleLocation?
    var position: Int = 0
    func configure(using location: VehicleLocation, position: Int) {
        self.location = location
        self.position = position
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        prepareForReuse()
    }

    override func prepareForReuse() {
        let index = min(10, 10 - position )
        let pinImage = UIImage(named: "sensor-\(index)")
        let size = CGSize(width: 38, height: 60)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()
        contentMode = .scaleAspectFit
        canShowCallout = false
        calloutOffset = .init(x: -8, y: 0)
        autoresizesSubviews = true
    }

    override func layoutSubviews() {
        prepareForReuse()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
