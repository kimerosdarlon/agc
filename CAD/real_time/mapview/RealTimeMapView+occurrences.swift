//
//  RealTimeMapView+occurrences.swift
//  CAD
//
//  Created by Samir Chaves on 05/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import AgenteDeCampoCommon

// Managing the rendering process of occurrences annotations
// and polyline overlays for routes
extension RealTimeMapView {
    func setOccurrences(_ occurrences: [SimpleOccurrence]) {
        let dispatchedOccurrence = cadService.getDispatchedOccurrence()
        let pinsToRemove = self.occurrencesPins.filter { pin in
            let occurrenceNotExists = !occurrences.contains(where: { $0.id == pin.occurrence.id })
            var occurrenceIsDispatched = false
            if let dispatchedOccurrence = dispatchedOccurrence,
               pin.occurrence.id == dispatchedOccurrence.occurrenceId {
                occurrenceIsDispatched = true
            }
            return occurrenceNotExists || occurrenceIsDispatched
        }

        pinsToRemove.forEach { self.mapView.removeAnnotation($0) }

        self.occurrencesPins = self.occurrencesPins.filter { !pinsToRemove.contains($0) }

        let occurrencesToAdd = occurrences.filter { occurrence in
            let pinNotExists = !self.occurrencesPins.contains(where: { $0.occurrence.id == occurrence.id })
            var occurrenceIsDispatched = false
            if let dispatchedOccurrence = dispatchedOccurrence,
               occurrence.id == dispatchedOccurrence.occurrenceId {
                occurrenceIsDispatched = true
            }
            return pinNotExists && !occurrenceIsDispatched
        }
        let pinsToAdd = occurrencesToAdd.map { occurrence -> OccurrenceAnnotation in
            let pin = OccurrenceAnnotation(occurrence: occurrence)
            if let coords = occurrence.address.coordinates {
                pin.coordinate = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
                pin.title = occurrence.natures.map { $0.name }.joined(separator: ", ")
            }
            return pin
        }
        mapView.addAnnotations(pinsToAdd)
        self.occurrencesPins.append(contentsOf: pinsToAdd)
    }

    func removeRoutes() {
        if let polylineOverlay = polylineOverlay {
            mapView.removeOverlay(polylineOverlay)
        }
    }

    func fitInOccurrences() {
        fit(in: occurrencesPins)
    }

    private func showRoute(to coordinates: CLLocationCoordinate2D, completion: @escaping () -> Void) {
        let source = userLocation.coordinate
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, _ in
            guard let unwrappedResponse = response else { return }
            garanteeMainThread {
                removeRoutes()
                if let route = unwrappedResponse.routes.first {
                    mapView.addOverlay(route.polyline)
                    polylineOverlay = route.polyline
                    mapView.setVisibleMapRect(
                        route.polyline.boundingMapRect,
                        edgePadding: UIEdgeInsets(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0),
                        animated: true
                    )
                    completion()
                }
            }
        }
    }

    func showRoute(to occurrence: SimpleOccurrence, completion: @escaping () -> Void) {
        if let destination = occurrence.address.coordinates?.toCLLocationCoordinate2D(),
           let selectedOccurrence = selectedOccurrence,
           occurrence.id == selectedOccurrence.id {
            showRoute(to: destination, completion: completion)
        }
    }

    func showRoute(to teamMember: PositionedTeamMember, completion: @escaping () -> Void) {
        let destination = CLLocationCoordinate2D(
            latitude: teamMember.position.latitude,
            longitude: teamMember.position.longitude
        )
        showRoute(to: destination, completion: completion)
    }

    func setOccurrencesLabelsVisibility(for annotations: [MKAnnotation]) {
        annotations.forEach { annotation  in
            if let annotation = annotation as? OccurrenceAnnotation,
               let annotationView = mapView.view(for: annotation) as? OccurrenceAnnotationView {
                if self.showOccurrencesLabels {
                    annotationView.showLabel()
                } else {
                    annotationView.hideLabel()
                }
            }
        }
    }

    @objc func didDispatchedOccurrenceLoad(_ notification: Notification) {
        guard let dispatchedOccurrence = cadService.getDispatchedOccurrence() else { return }
        removeDispatchedOccurrencePin()
        let annotation = DispatchOccurrenceAnnotation(occurrence: dispatchedOccurrence)
        mapView.addAnnotation(annotation)
    }

    @objc func removeDispatchedOccurrencePin() {
        let occurrencesAnnotations = mapView.annotations.filter { annotation in
            if let annotation = annotation as? DispatchOccurrenceAnnotation,
               annotation.coordinate.latitude != 0,
               annotation.coordinate.longitude != 0 {
                return true
            }
            return false
        }
        mapView.removeAnnotations(occurrencesAnnotations)
    }
}
