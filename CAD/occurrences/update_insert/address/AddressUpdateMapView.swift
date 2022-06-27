//
//  AddressUpdateMapView.swift
//  CAD
//
//  Created by Samir Chaves on 19/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import MapKit
import UIKit

class AddressUpdateMapView: UIView {
    weak var mapLocatorDelegate: MapLocatorViewDelegate?
    weak var parentViewController: UIViewController?

    @GeocodingServiceInject
    private var geocodingService: GeocodingService

    private(set) var occurrenceCoordinates: CLLocationCoordinate2D?

    private let mapView: MKMapView = {
        let mapView = MKMapView().enableAutoLayout()
        mapView.layer.cornerRadius = 7
        return mapView
    }()

    private let pinButton: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        let icon = UIImage(systemName: "mappin")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let height: CGFloat = 35
        btn.setTitle("Marque o local no mapa", for: .normal)
        btn.setTitleColor(.appTitle, for: .normal)
        btn.setImage(icon, for: .normal)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        btn.imageEdgeInsets.left = -10
        btn.layer.cornerRadius = height / 2
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.6).cgColor
        btn.clipsToBounds = true
        btn.titleLabel?.font = .boldSystemFont(ofSize: 13)
        btn.addTarget(self, action: #selector(didTapOnPinButton), for: .touchUpInside)
        return btn.height(height).width(200)
    }()

    init(occurrenceCoordinates: CLLocationCoordinate2D?) {
        super.init(frame: .zero)
        self.occurrenceCoordinates = occurrenceCoordinates
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(mapView)
        addSubview(pinButton)

        mapView.fillSuperView()

        NSLayoutConstraint.activate([
            pinButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            pinButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])

        if let occurrenceCoordinates = self.occurrenceCoordinates {
            setOccurrenceCoordinates(occurrenceCoordinates)
        }

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial)).enableAutoLayout()
        blurView.frame = pinButton.bounds
        blurView.isUserInteractionEnabled = false
        pinButton.insertSubview(blurView, at: 0)

        NSLayoutConstraint.activate([
            pinButton.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            pinButton.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            pinButton.topAnchor.constraint(equalTo: blurView.topAnchor),
            pinButton.bottomAnchor.constraint(equalTo: blurView.bottomAnchor)
        ])

        if let imageView = pinButton.imageView {
            imageView.backgroundColor = .clear
            pinButton.bringSubviewToFront(imageView)
        }
    }

    func setOccurrenceCoordinates(_ coordinates: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Local da Ocorrência"
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }

    func searchAddress(query: String, completion: @escaping (GeocodeResult?) -> Void) {
        geocodingService.geocode(address: query) { result in
            garanteeMainThread {
                switch result {
                case .success(let geocodeResults):
                    guard let result = geocodeResults.first else { return }
                    self.setOccurrenceCoordinates(result.position.toCLCoordinate())
                    completion(result)
//                    self.mapLocatorDelegate?.didConfirmChanges(address: result.address, position: result.position.toCLCoordinate())
                case .failure(let error as NSError):
                    completion(nil)
                    guard let parentViewController = self.parentViewController else { return }
                    Toast.present(in: parentViewController, message: error.domain)
                }
            }
        }
    }

    @objc private func didTapOnPinButton() {
        let mapLocator = MapLocatorViewController(occurrenceCoordinates: occurrenceCoordinates)
        mapLocator.delegate = mapLocatorDelegate
        parentViewController?.present(mapLocator, animated: true)
    }
}
