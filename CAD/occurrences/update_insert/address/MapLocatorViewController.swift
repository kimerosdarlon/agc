//
//  AddressUpdateMapLocator.swift
//  CAD
//
//  Created by Samir Chaves on 19/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import MapKit
import UIKit
import Location

protocol MapLocatorViewDelegate: class {
    func didConfirmChanges(address: GeocodeAddress, position: CLLocationCoordinate2D)
}

class MapLocatorViewController: UIViewController {
    weak var delegate: MapLocatorViewDelegate?

    private let mapView = MKMapView().enableAutoLayout()

    private let closeBtn: UIButton = {
        let btn = UIButton(type: .close).enableAutoLayout()
        btn.addTarget(self, action: #selector(didTapOnCloseBtn), for: .touchUpInside)
        return btn
    }()

    private let userPositionButton: UIButton = {
        let size: CGFloat = 42
        let image = UIImage(named: "blueTarget")
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        btn.layer.cornerRadius = size / 2
        btn.backgroundColor = .white
        btn.isUserInteractionEnabled = true
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = .init(width: 0, height: 7)
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowRadius = 3
        btn.addTarget(self, action: #selector(didTapOnUserPositionButton), for: .touchUpInside)
        return btn.enableAutoLayout().width(size).height(size)
    }()

    private let pinIcon: UIImageView = {
        let view = UIImageView(frame: .init(x: 0, y: 0, width: 15, height: 40))
        view.image =  UIImage(systemName: "mappin")?
            .withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        return view.enableAutoLayout()
    }()

    private let searchLabel = UILabel.build(withSize: 12, text: "Endereço")

    private let searchField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .appBackgroundCell
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 20))
        textField.layer.cornerRadius = 5
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.enableAutoLayout()
        textField.height(40)
        textField.addTarget(self, action: #selector(didChangeSearch), for: .editingChanged)
        return textField
    }()

    private let searchBtn: UIButton = {
        let btn = AGCRoundedButton(text: "Definir local no mapa").enableAutoLayout()
        btn.addTarget(self, action: #selector(didTapOnSearchBtn), for: .touchUpInside)
        return btn
    }()

    private let searchContainerView: UIView = {
        let view = UIView()
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 8
        view.backgroundColor = .appBackground
        return view.enableAutoLayout()
    }()

    private let progressBar = IndeterminateProgressBar().enableAutoLayout()

    @GeocodingServiceInject
    private var geocodingService: GeocodingService

    private var formattedAddress = ""

    private let geocodeReverseDebounce = Debouncer(timeInterval: 1)
    private let geocodeDebounce = Debouncer(timeInterval: 1)

    private let locationService = LocationService.shared

    private let occurrenceCoordinates: CLLocationCoordinate2D?

    private var selectedAddress: GeocodeAddress?
    private var selectedPosition: CLLocationCoordinate2D?

    init(occurrenceCoordinates: CLLocationCoordinate2D?) {
        self.occurrenceCoordinates = occurrenceCoordinates

        super.init(nibName: nil, bundle: nil)
        mapView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        view.addSubview(pinIcon)
        view.addSubview(closeBtn)
        view.addSubview(userPositionButton)
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(progressBar)
        searchContainerView.addSubview(searchLabel)
        searchContainerView.addSubview(searchField)
        searchContainerView.addSubview(searchBtn)
        searchContainerView.clipsToBounds = true

        presentationController?.presentedView?.gestureRecognizers?.forEach { $0.isEnabled = false }

        searchField.height(40)

        mapView.fillSuperView(regardSafeArea: false)
        mapView.showsUserLocation = true

        closeBtn.height(45).width(45)
        pinIcon.height(40).width(32)
        searchBtn.height(40)
        progressBar.height(2)

        var safeAreaBottomPadding: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            safeAreaBottomPadding = window?.safeAreaInsets.bottom ?? 0
        }

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            closeBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),

            pinIcon.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            pinIcon.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -20),

            searchContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            searchContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            searchContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchContainerView.topAnchor.constraint(equalTo: searchLabel.topAnchor, constant: -15),

            userPositionButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            userPositionButton.bottomAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: -20),

            progressBar.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),

            searchLabel.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 15),
            searchLabel.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -15),

            searchField.leadingAnchor.constraint(equalTo: searchLabel.leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: searchLabel.trailingAnchor),
            searchField.topAnchor.constraint(equalTo: searchLabel.bottomAnchor, constant: 10),

            searchBtn.leadingAnchor.constraint(equalTo: searchLabel.leadingAnchor),
            searchBtn.trailingAnchor.constraint(equalTo: searchLabel.trailingAnchor),
            searchBtn.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            searchBtn.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: -(safeAreaBottomPadding + 10))
        ])

        if let occurrenceCoordinates = self.occurrenceCoordinates {
            let coordinateRegion = MKCoordinateRegion(center: occurrenceCoordinates, latitudinalMeters: 800, longitudinalMeters: 800)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }

    private func fetchAddressFrom(coordinates: CLLocationCoordinate2D) {
        progressBar.isLoading = true
        geocodingService.reverseGeocode(lat: coordinates.latitude, lng: coordinates.longitude) { result in
            garanteeMainThread {
                self.progressBar.isLoading = false
                switch result {
                case .success(let reverseGeocode):
                    guard let result = reverseGeocode.addresses.first else { return }
                    self.selectedAddress = result.address
                    self.selectedPosition = coordinates
                    self.searchField.text = result.address.freeformAddress
                case .failure(let error as NSError):
                    Toast.present(in: self, message: error.domain)
                    self.formattedAddress = "Não foi possível recuperar esse endereço."
                }
            }
        }
    }

    func fetchAddressFrom(query: String) {
        progressBar.isLoading = true
        geocodingService.geocode(address: query) { result in
            garanteeMainThread {
                self.progressBar.isLoading = false
                switch result {
                case .success(let geocodeResults):
                    guard let result = geocodeResults.first else { return }
//                    self.searchField.text = result.address.freeformAddress
                    self.selectedAddress = result.address
                    self.selectedPosition = result.position.toCLCoordinate()
                    self.navigateTo(coordinate: result.position.toCLCoordinate())
                case .failure(let error as NSError):
                    Toast.present(in: self, message: error.domain)
                }
            }
        }
    }

    fileprivate func regionDidChange(centerCoordinates: CLLocationCoordinate2D) {
        geocodeReverseDebounce.renewInterval()
        geocodeReverseDebounce.handler = {
            self.fetchAddressFrom(coordinates: centerCoordinates)
        }
    }

    @objc private func didTapOnCloseBtn() {
        dismiss(animated: true)
    }

    private func navigateTo(coordinate: CLLocationCoordinate2D) {
        if CLLocationCoordinate2DIsValid(coordinate) && coordinate.latitude != 0 && coordinate.longitude != 0 {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            self.mapView.setRegion(region, animated: true)
        }
    }

    @objc private func didTapOnUserPositionButton() {
        guard let coordinate = self.locationService.currentLocation?.coordinate else { return }
        regionDidChange(centerCoordinates: coordinate)
        navigateTo(coordinate: coordinate)
    }

    @objc private func didChangeSearch(_ sender: UITextField) {
        guard let query = sender.text else { return }
        geocodeDebounce.renewInterval()
        geocodeDebounce.handler = {
            self.fetchAddressFrom(query: query)
        }
    }

    @objc private func didTapOnSearchBtn() {
        guard let selectedAddress = self.selectedAddress,
              let selectedPosition = self.selectedPosition else { return }
        self.dismiss(animated: true) {
            self.delegate?.didConfirmChanges(address: selectedAddress, position: selectedPosition)
        }
    }

    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state == .began || recognizer.state == .ended {
                    return true
                }
            }
        }
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension MapLocatorViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
            regionDidChange(centerCoordinates: mapView.centerCoordinate)
        }
    }
}
