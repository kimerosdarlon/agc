//
//  RealTimeMapView.swift
//  CAD
//
//  Created by Samir Chaves on 10/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import AgenteDeCampoCommon
import Location

protocol RealTimeMapViewDelegate: class {
    func userLocationDidChangeStatus(_ status: LocationStatus)
    func pinnedLocationDidChange(_ location: CLLocationCoordinate2D)
    func didSelectOccurrenceAnnotation(_ occurrence: SimpleOccurrence)
    func didSelectDispatchedOccurrenceAnnotation(_ occurrence: SimpleOccurrence)
    func didSelectTeamAnnotation(_ teamId: UUID)
    func didSelectTeamMemberAnnotation(_ memberCpf: String, fromTeam teamId: UUID)
}

extension RealTimeMapViewDelegate {
    func userLocationDidChangeStatus(_ status: LocationStatus) { }
    func pinnedLocationDidChange(_ location: CLLocationCoordinate2D) { }
}

class RealTimeMapView: SecureView {
    weak var delegate: RealTimeMapViewDelegate?
    internal var mapView: MKMapView = {
        let map = MKMapView()
        map.enableAutoLayout()
        map.showsUserLocation = true
        map.userTrackingMode = .followWithHeading
        return map
    }()
    internal var isEditingRadius: Bool = false

    private var locationService = LocationService.shared

    @CadServiceInject
    internal var cadService: CadService

    var userLocation: MKUserLocation {
        mapView.userLocation
    }

    var pinnedPosition: CLLocationCoordinate2D?

    internal enum TeamsViewState {
        case teamsPins, teamMembersPins
    }

    private var locationStatusService: LocationService?
    private var windowTopPadding: CGFloat = 0
    private var regionChangingTimer: Timer?
    private var userLocationAnnotationView: UserLocationAnnotationView?
    internal var teamsManager = TeamMembersManager.shared
    internal var circleOverlay: MKCircle?
    internal var polylineOverlay: MKPolyline?
    internal var pin: MKPointAnnotation?
    internal var occurrencesPins = [OccurrenceAnnotation]()
    internal var teamsViewState: TeamsViewState = .teamsPins
    internal var pinsByTeam = [UUID: [TeamMemberAnnotation]]()
    internal var positionsByTeam = [UUID: [PositionEvent]]()
    internal var initialRadius: CGFloat = 1000
    internal var showOccurrencesLabels: Bool = false {
        didSet {
            if showOccurrencesLabels != oldValue {
                self.setOccurrencesLabelsVisibility(for: mapView.annotations)
                self.setTeamLabelsVisibility(for: mapView.annotations)
            }
        }
    }
    private var circleInitiallyPositioned = false
    var selectedOccurrence: SimpleOccurrence?

    init(delegate: RealTimeMapViewDelegate? = nil) {
        super.init(frame: .zero)
        self.delegate = delegate
        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            windowTopPadding = window.safeAreaInsets.top
        }

        initialRadius = CGFloat(ExternalSettingsService.settings.realTime.radiusSize)

        addSubview(mapView)
        mapView.enableAutoLayout().fillSuperView()
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnMap(_:))))
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(userLocationStatusDidChange), name: .userLocationStatusDidChange, object: nil)
        if let circleCenter = locationService.currentLocation?.coordinate, cadService.realtimeOccurrencesAllowed() {
            setCircle(center: circleCenter, radius: Double(initialRadius))
        }

        center.addObserver(self, selector: #selector(userHeadingDidChange(_:)), name: .userHeadingDidChange, object: nil)
        center.addObserver(self, selector: #selector(didDispatchedOccurrenceLoad(_:)), name: .cadDidDispatchedOccurrenceLoad, object: nil)
        center.addObserver(self, selector: #selector(removeDispatchedOccurrencePin), name: .cadTeamDidFinishDispatch, object: nil)

        mapView.register(CirclePinAnnotationView.self, forAnnotationViewWithReuseIdentifier: CirclePinAnnotationView.identifier)
        mapView.register(OccurrenceAnnotationView.self, forAnnotationViewWithReuseIdentifier: OccurrenceAnnotationView.identifier)
        mapView.register(UserLocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: UserLocationAnnotationView.identifier)
        mapView.register(MyTeamMemberAnnotationView.self, forAnnotationViewWithReuseIdentifier: MyTeamMemberAnnotationView.childIdentifier)
        mapView.register(TeamMemberAnnotationView.self, forAnnotationViewWithReuseIdentifier: TeamMemberAnnotationView.identifier)
        mapView.register(DispatchOccurrenceAnnotationView.self, forAnnotationViewWithReuseIdentifier: DispatchOccurrenceAnnotationView.identifier)

        // Workaround to remove the native delay of annotation selection on tap
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        gestureRecognizer.numberOfTapsRequired = 1
//        gestureRecognizer.numberOfTouchesRequired = 1
//        mapView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // disabling zoom, so the didSelect triggers immediately
        mapView.isZoomEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.isZoomEnabled = true
        }
    }

    @objc private func userHeadingDidChange(_ notificaton: Notification) {
        setHeadingRotation()
    }

    @objc private func didTapOnMap(_ gesture: UITapGestureRecognizer) {
        if isEditingRadius {
            let point = gesture.location(in: mapView)
            let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
            setPin(location: coordinates)
        }
    }

    func getLocationStatus() {
        let status = LocationService.status
        delegate?.userLocationDidChangeStatus(status)
    }

    func navigateTo(_ coordinates: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }

    func navigateTo(_ occurrence: SimpleOccurrence) {
        if let coordinates = occurrence.address.coordinates {
            let coordinates2D = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            navigateTo(coordinates2D)
        }
    }

    @objc private func userLocationStatusDidChange() {
        delegate?.userLocationDidChangeStatus(LocationService.status)
    }

    func centerMap() {
        guard let coordinate = self.locationService.currentLocation?.coordinate else { return }
        if CLLocationCoordinate2DIsValid(coordinate) && coordinate.latitude != 0 && coordinate.longitude != 0 {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            self.mapView.setRegion(region, animated: true)
        }
    }

    func translateMap(_ translation: CGFloat) {
        mapView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: translation)
        mapView.layoutMargins = UIEdgeInsets(top: -translation + windowTopPadding + 30, left: 15, bottom: -translation + 2, right: 18)
    }

    private func setHeadingRotation() {
        if let accurrancy = locationService.headingAccuracy,
           accurrancy < 50, accurrancy > 0 {
            var mapHeading = self.mapView.camera.heading
            if mapHeading < 0 {
                mapHeading = abs(mapHeading)
            } else if mapHeading > 0 {
                mapHeading = 360 - mapHeading
            }

            var offsetHeading = (locationService.trueHeading ?? 0) + mapHeading
            while offsetHeading > 360.0 {
                offsetHeading -= 360.0
            }

            let headingInRadians = offsetHeading * Double.pi / 180
            let tranformation = CGAffineTransform(rotationAngle: CGFloat(headingInRadians))
            userLocationAnnotationView?.layer.setAffineTransform(tranformation)
        } else {
            userLocationAnnotationView?.heading.alpha = 1
        }
    }

    internal func distance(from point1: CLLocationCoordinate2D, to point2: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(coordinate: point1, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        let location2 = CLLocation(coordinate: point2, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        return location1.distance(from: location2).magnitude
    }

    func fit(in annotations: [MKAnnotation]) {
        if !annotations.isEmpty {
            let lats = annotations.map { $0.coordinate.latitude }
            let lngs = annotations.map { $0.coordinate.longitude }
            let topLeftCoord = CLLocationCoordinate2D(latitude: lats.max()!, longitude: lngs.min()!)
            let topRightCoord = CLLocationCoordinate2D(latitude: lats.max()!, longitude: lngs.max()!)
            let bottomRightCoord = CLLocationCoordinate2D(latitude: lats.min()!, longitude: lngs.max()!)
            let horizontalDistance = distance(from: topLeftCoord, to: topRightCoord)
            let verticalDistance = distance(from: topRightCoord, to: bottomRightCoord)
            let centerLat = topRightCoord.latitude + (bottomRightCoord.latitude - topRightCoord.latitude) / 2
            let centerLng = topLeftCoord.longitude + (topRightCoord.longitude - topLeftCoord.longitude) / 2
            let centerCoordinate = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
            let region = MKCoordinateRegion(
                center: centerCoordinate,
                latitudinalMeters: verticalDistance + 500,
                longitudinalMeters: horizontalDistance + 500
            )
            mapView.setRegion(region, animated: true)
        }
    }
}

extension RealTimeMapView: MKMapViewDelegate {
    private func checkOccurrencesLabelsVisibility() {
        let minDelta = min(mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta)
        if minDelta < 0.005 {
            self.showOccurrencesLabels = true
        } else {
            self.showOccurrencesLabels = false
        }
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !circleInitiallyPositioned && userLocation.coordinate.latitude != 0 && userLocation.coordinate.longitude != 0 {
            if cadService.realtimeOccurrencesAllowed() {
                setCircle(center: userLocation.coordinate)
            }
            circleInitiallyPositioned = true
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverLay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverLay)
            circleRenderer.fillColor = UIColor.appTitle.withAlphaComponent(0.3)
            circleRenderer.alpha = 0.4
            return circleRenderer
        } else if let polylineOverLay = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polylineOverLay)
            renderer.strokeColor = .appBlue
            renderer.lineWidth = 5.0
            return renderer
        } else {
            return MKPolylineRenderer(overlay: overlay)
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let visibleAnnotations: [MKAnnotation] = self.mapView.annotations(in: mapView.visibleMapRect)
            .filter { $0 is MKAnnotation }
            .map { $0 as! MKAnnotation }
        self.setOccurrencesLabelsVisibility(for: visibleAnnotations)
        self.setTeamLabelsVisibility(for: visibleAnnotations)
        self.setHeadingRotation()
    
        regionChangingTimer?.invalidate()
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        regionChangingTimer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { _ in
            self.setHeadingRotation()
            self.checkOccurrencesLabelsVisibility()
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is CirclePinAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: CirclePinAnnotationView.identifier)
        }

        if annotation is OccurrenceAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: OccurrenceAnnotationView.identifier)
        }

        if annotation is MyTeamMemberAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: MyTeamMemberAnnotationView.childIdentifier)
        }

        if annotation is TeamMemberAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: TeamMemberAnnotationView.identifier)
        }

        if annotation is DispatchOccurrenceAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: DispatchOccurrenceAnnotationView.identifier)
        }

        if annotation is MKUserLocation {
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: UserLocationAnnotationView.identifier) as? UserLocationAnnotationView else { return nil }
            userLocationAnnotationView = annotationView
            return annotationView
        }
    
        return nil
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.isZoomEnabled = true
        if view is OccurrenceAnnotationView,
           let annotation = view.annotation as? OccurrenceAnnotation {
            delegate?.didSelectOccurrenceAnnotation(annotation.occurrence)
        }

        if view is DispatchOccurrenceAnnotationView,
           let annotation = view.annotation as? DispatchOccurrenceAnnotation {
            let simpleOccurrence = annotation.occurrence.toSimple(allocatedTeams: [])
            delegate?.didSelectDispatchedOccurrenceAnnotation(simpleOccurrence)
        }

        if view is TeamMemberAnnotationView,
           let annotation = view.annotation as? TeamMemberAnnotation {
            let coordinates = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            navigateTo(coordinates)
            delegate?.didSelectTeamAnnotation(annotation.teamId)
            delegate?.didSelectTeamMemberAnnotation(annotation.memberCpf, fromTeam: annotation.teamId)
            
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}
