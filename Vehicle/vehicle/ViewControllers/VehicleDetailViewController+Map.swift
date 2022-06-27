//
//  VehicleDetailViewController+Map.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 04/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import MapKit

extension VehicleDetailViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation =  view as? CustomPinAnnotationView {
            if let location = annotation.location {
                self.selectedLocation = location
                self.locationDetailView.configure(with: location)
                let center = location.coordinate
                let region = MKCoordinateRegion(center: center, span: .init(latitudeDelta: 0.025, longitudeDelta: 0.025))
                mapView.setRegion(region, animated: true)
            }
            UIView.animate(withDuration: 0.3, animations: {self.toggleDetailFooter(reveal: true)})
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.3) {
            self.toggleDetailFooter(reveal: false)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation) as! CustomPinAnnotationView
        if let location = annotation as? VehicleLocation {
            do {
            annotationView.configure(using: location, position: try location.getRankingIn(dates: locationDates, order: .orderedDescending)  )
            } catch {
                NSLog("ERROR: não foi possível obter o raking da data")
            }
        }
        return annotationView
    }
}
