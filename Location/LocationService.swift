//
//  LocationService.swift
//  CAD
//
//  Created by Samir Chaves on 10/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import MapKit
import CoreData

public class LocationService: NSObject {
    public static let shared: LocationService = LocationService()

    private static let key = "locationStatus"
    private let locationManager: CLLocationManager

    public static var status: LocationStatus {
        get {
            let userDefaults = UserDefaults.standard
            guard let statusString = userDefaults.string(forKey: key) else { return .notDetermined }
            return LocationStatus.init(rawValue: statusString)!
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue.rawValue, forKey: key)
        }
    }

    public var trueHeading: CLLocationDirection? {
        return locationManager.heading?.trueHeading
    }

    public var headingAccuracy: CLLocationDirection? {
        return locationManager.heading?.headingAccuracy
    }

    public var currentLocation: CLLocation? {
        return locationManager.location
    }

    public override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }

    public func requestUserLocation() {
        locationManager.requestAlwaysAuthorization()
    }

    public func startMonitoring(region: CLRegion) {
        locationManager.startMonitoring(for: region)
    }

    public func stopMonitoring(region: CLRegion) {
        locationManager.stopMonitoring(for: region)
    }

    public func stopMonitoringAllRegions() {
        locationManager.monitoredRegions.forEach { region in
            self.locationManager.stopMonitoring(for: region)
        }
    }

    public func startUpdatingLocation() {
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NotificationCenter.default.post(name: .didUserEnterRegion, object: region)
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NotificationCenter.default.post(name: .didUserExitRegion, object: region)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            LocationService.status = .always
        case .authorizedWhenInUse:
            LocationService.status = .whenInUse
        case .restricted, .denied:
            LocationService.status = .denied
        case .notDetermined:
            LocationService.status = .notDetermined
        @unknown default:
            LocationService.status = .notDetermined
        }
        let center = NotificationCenter.default
        center.post(name: .userLocationStatusDidChange, object: nil)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        NotificationCenter.default.post(name: .userHeadingDidChange, object: newHeading.trueHeading)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            NotificationCenter.default.post(name: .userLocationDidChange, object: nil, userInfo: [
                "location": lastLocation
            ])
        }
    }
}

public enum LocationStatus: String {
    case notDetermined
    case whenInUse
    case always
    case denied

    public var isAuthorized: Bool {
        return self == .always || self == .whenInUse
    }
}
