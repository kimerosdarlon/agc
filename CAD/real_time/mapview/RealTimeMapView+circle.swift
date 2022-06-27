//
//  RealTimeMapView+circle.swift
//  CAD
//
//  Created by Samir Chaves on 05/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// Managing search radius circle overlay on RealTime Map View
extension RealTimeMapView {
    internal func setPin(location: CLLocationCoordinate2D) {
        pinnedPosition = location
        if let pin = pin {
            mapView.removeAnnotation(pin)
        }
        let pin = CirclePinAnnotation()
        pin.coordinate = location
        mapView.addAnnotation(pin)
        self.pin = pin
        delegate?.pinnedLocationDidChange(location)
        setCircle(center: location)
    }

    internal func updateCircleStyle() {
        if let radius = self.circleOverlay?.radius {
            setCircle(radius: radius)
        }
    }

    internal func setCircle(center: CLLocationCoordinate2D) {
        if let radius = self.circleOverlay?.radius {
            setCircle(center: center, radius: radius)
        }
    }

    internal func setCircle(radius: CLLocationDistance) {
        if let center = self.circleOverlay?.coordinate {
            setCircle(center: center, radius: radius)
        }
    }

    internal func setCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        if let circleOverlay = circleOverlay {
            mapView.removeOverlay(circleOverlay)
        }
        let circleOverlay = MKCircle(center: center, radius: radius)
        mapView.addOverlay(circleOverlay)
        self.circleOverlay = circleOverlay
    }

    func beginEditingRadius() {
        isEditingRadius = true
        updateCircleStyle()
    }

    func endEditingRadius() {
        isEditingRadius = false
        updateCircleStyle()
    }

    func updateCircle(radius: CGFloat) {
        if let center = self.circleOverlay?.coordinate, isEditingRadius {
            let region = MKCoordinateRegion(center: center, latitudinalMeters: .init(radius * 2.1), longitudinalMeters: .init(radius * 2.1))
            mapView.setRegion(region, animated: true)
            setCircle(center: center, radius: CLLocationDistance(radius))
        }
    }

    func updateCircle(radius: CGFloat, location: CLLocationCoordinate2D) {
        setPin(location: location)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: .init(radius * 2.1), longitudinalMeters: .init(radius * 2.1))
        mapView.setRegion(region, animated: true)
        setCircle(center: location, radius: CLLocationDistance(radius))
    }

    func getCircleRadius() -> CGFloat {
        return (self.circleOverlay?.radius.magnitude).map { radius in
            radius == 0 ? initialRadius : CGFloat(radius)
        } ?? initialRadius
    }

    func getCirclePosition() -> CLLocationCoordinate2D {
        return self.circleOverlay?.coordinate ?? mapView.userLocation.coordinate
    }
}
