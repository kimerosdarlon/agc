//
//  OccurrencePreviewViewController.swift
//  CAD
//
//  Created by Samir Chaves on 08/10/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import MapKit
import Location

class OccurrencePreviewViewController: UIViewController {
    private var occurrenceDetailsView: RecentOccurrenceViewController?
    private let occurrenceDetails: OccurrenceDetails
    private var currentTeams = [SimpleTeam]()
    private var occurrenceCoordinate: CLLocationCoordinate2D?
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    private let loadingView = UIActivityIndicatorView().enableAutoLayout()
    private let errorLabel = UILabel.build(withSize: 12, color: .appRed, alignment: .center)
    private let errorView: UIView = UIView().enableAutoLayout()
    private let locationErrorView: UIView = {
        let view = UIView()
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(blurView)
        let textLabel = UILabel.build(withSize: 15, color: .appTitle, alignment: .center, text: "A ocorrência atual não foi georreferenciada")
        view.addSubview(textLabel)
        textLabel.centerY(view: view).centerX(view: view).width(view.widthAnchor, multiplier: 0.9)
        view.isHidden = true
        return view.enableAutoLayout()
    }()
    private var mapView = MKMapView().enableAutoLayout()

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    @CadServiceInject
    private var cadService: CadService

    private let locationService = LocationService.shared

    init(occurrence: OccurrenceDetails) {
        occurrenceDetails = occurrence
        if let occurrenceLatitude = occurrence.address.coordinates?.latitude,
           let occurrenceLongitude = occurrence.address.coordinates?.longitude {
            occurrenceCoordinate = CLLocationCoordinate2D(latitude: occurrenceLatitude, longitude: occurrenceLongitude)
        }
        super.init(nibName: nil, bundle: nil)

        initialize()

        let simpleOccurrence = occurrence.toSimple(allocatedTeams: [])
        occurrenceDetailsView = RecentOccurrenceViewController(occurrence: simpleOccurrence, showDispatches: false)
    }

    private func initialize() {
        modalPresentationStyle = .custom
        transitionDelegate = DefaultModalPresentationManager(heightFactor: 0.9, position: .center)
        transitioningDelegate = transitionDelegate

        mapView.register(OccurrenceAnnotationView.self, forAnnotationViewWithReuseIdentifier: OccurrenceAnnotationView.identifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func startLoading() {
        loadingView.startAnimating()
        loadingView.isHidden = false
    }

    private func stopLoading() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
    }

    private func showError(error: NSError) {
        errorView.isHidden = false
        errorLabel.text = error.domain
    }

    private func hideError() {
        errorView.isHidden = true
        errorLabel.text = nil
    }

    private func showLocationError() {
        locationErrorView.isHidden = false
    }

    private func setOccurrencePin(location: CLLocationCoordinate2D) {
        let annotation = OccurrenceAnnotation(occurrence: occurrenceDetails.toSimple())
        annotation.coordinate = location
        annotation.title = "Local da Ocorrência"
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }

    private func showUserRoute(occurrenceCoordinates: CLLocationCoordinate2D) {
        setOccurrencePin(location: occurrenceCoordinates)
        if let currentLocation = locationService.currentLocation {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: occurrenceCoordinates, addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile

            let directions = MKDirections(request: request)

            directions.calculate { [weak self] response, _ in
                garanteeMainThread {
                    guard let unwrappedResponse = response else { return }
                    if let route = unwrappedResponse.routes.first {
                        self?.mapView.addOverlay(route.polyline)
                        self?.mapView.setVisibleMapRect(
                            route.polyline.boundingMapRect,
                            edgePadding: UIEdgeInsets(top: 80.0, left: 30.0, bottom: 100.0, right: 30.0),
                            animated: true
                        )
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(loadingView)
        view.addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorLabel.centerX(view: errorView).centerY(view: errorView)
        errorView.isHidden = true
        loadingView.isHidden = true
        view.addSubview(mapView)
        view.addSubview(locationErrorView)

        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 300),

            locationErrorView.topAnchor.constraint(equalTo: mapView.topAnchor),
            locationErrorView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            locationErrorView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            locationErrorView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])

        renderPreview()

        if let occurrenceCoordinate = occurrenceCoordinate {
            self.showUserRoute(occurrenceCoordinates: occurrenceCoordinate)
        } else {
            self.showLocationError()
        }
    }

    private func renderPreview() {
        guard let occurrenceDetailsView = occurrenceDetailsView else { return }
        view.addSubview(occurrenceDetailsView.view.enableAutoLayout())
        addChild(occurrenceDetailsView)

        occurrenceDetailsView.delegate = self
        setupPreviewLayout()
    }

    private func setupPreviewLayout() {
        guard let occurrenceDetailsView = occurrenceDetailsView else { return }
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            occurrenceDetailsView.view.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            occurrenceDetailsView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            occurrenceDetailsView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            occurrenceDetailsView.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            loadingView.topAnchor.constraint(equalTo: occurrenceDetailsView.view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: occurrenceDetailsView.view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: occurrenceDetailsView.view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: occurrenceDetailsView.view.bottomAnchor),

            errorView.topAnchor.constraint(equalTo: occurrenceDetailsView.view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: occurrenceDetailsView.view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: occurrenceDetailsView.view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: occurrenceDetailsView.view.bottomAnchor)
        ])
        view.layoutIfNeeded()
    }

    private func getStoredOccurrence() -> OccurrenceDetails? {
        guard let jsonString = UserDefaults.standard.string(forKey: "cached_dispatched_occurrence"),
              let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(OccurrenceDetails.self, from: data)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension OccurrencePreviewViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polylineOverLay = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polylineOverLay)
            renderer.strokeColor = .appBlue
            renderer.lineWidth = 5.0
            return renderer
        }

        return MKPolylineRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is OccurrenceAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: OccurrenceAnnotationView.identifier)
        }

        return nil
    }
}

extension OccurrencePreviewViewController: RecentOccurrenceDelegate {
    func didBack() {
        dismiss(animated: true)
    }

    private func goToOccurrenceDetails(_ occurrence: OccurrenceDetails) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .cadDidDetailAnOccurrence, object: nil, userInfo: [
                "details": occurrence
            ])
        })
    }

    func didTapInDetailsButton(_ occurrenceId: UUID, completion: @escaping () -> Void) {
        occurrenceService.getOccurrenceById(occurrenceId) { result in
            garanteeMainThread {
                switch result {
                case .success(let occurrenceDetails):
                    self.goToOccurrenceDetails(occurrenceDetails)
                    completion()
                case .failure(let error as NSError):
                    if error.code == 100 || error.code > 500 {
                        guard let cachedOccurrence = self.getStoredOccurrence() else { return }
                        self.goToOccurrenceDetails(cachedOccurrence)
                    } else {
                        let parentViewController = self.presentingViewController
                        if self.isUnauthorized(error) {
                            self.dismiss(animated: true, completion: {
                                parentViewController?.gotoLogin(error.domain)
                            })
                        }
                        Toast.present(in: self, message: error.domain)
                    }
                    completion()
                }
            }
        }
    }
}
