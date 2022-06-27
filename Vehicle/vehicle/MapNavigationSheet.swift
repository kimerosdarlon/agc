//
//  MapNavigationSheet.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import MapKit
import Logger

protocol MapNavigationSheetDelagate: UIViewController {

}

class MapNavigationSheet {
    private lazy var logger = Logger.forClass(Self.self)
    let location: VehicleLocation
    weak var delegate: MapNavigationSheetDelagate?

    init(location: VehicleLocation) {
        self.location = location
    }

    func showOptions() {
        let latitule = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let wazeUrl = URL.init(string: "waze://")!
        let googleUrl = URL.init(string: "comgooglemaps://")!
        //        let mapsUrl = URL.init(string: "http://maps.apple.com")!
        var actions = [UIAlertAction]()
        let hasWaze = UIApplication.shared.canOpenURL(wazeUrl)
        let hasGoogleMaps = UIApplication.shared.canOpenURL(googleUrl)
        //        let hasAppleMaps = UIApplication.shared.canOpenURL(mapsUrl)

        let wazeAction = UIAlertAction(title: "Waze", style: .default) { (_) in
            self.gotoWaze(latitude: latitule, longitude: longitude)
        }

        let googleMapAction = UIAlertAction(title: "Google Maps", style: .default) { (_) in
            self.gotoGoogleMaps(latitude: latitule, longitude: longitude)
        }

        //        let appleMapAction = UIAlertAction(title: "Apple Maps", style: .default) { (_) in
        //            self.gotoMaps(latitude: latitule, longitude: longitude)
        //        }

        if hasWaze { actions.append(wazeAction) }
        if hasGoogleMaps { actions.append(googleMapAction) }
        //        if hasAppleMaps { actions.append(appleMapAction) }

        if actions.isEmpty {
            delegate?.alert(error: "Você precisa instalar pelo menos um aplicativo de Mapas.")
            return
        }

        if actions.count > 1 {
            let controller = UIAlertController(title: "Selecione o aplicativo de mapas.", message: nil, preferredStyle: .actionSheet)
            actions.forEach({ controller.addAction($0) })
            let cancel = UIAlertAction(title: "cancelar", style: .cancel, handler: nil)
            controller.addAction(cancel)
            delegate?.present(controller, animated: true, completion: nil)
        } else {
            if hasGoogleMaps { gotoGoogleMaps(latitude: latitule, longitude: longitude) }
            if hasWaze { gotoWaze(latitude: latitule, longitude: longitude) }
            //            else if hasAppleMaps { gotoMaps(latitude: latitule, longitude: longitude) }
        }
    }

    fileprivate func openUrl(_ str: String) {
        if let url = URL.init(string: str) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func gotoWaze(latitude: Double, longitude: Double) {
        let str = "https://waze.com/ul?ll=\(latitude),\(longitude)&navigate=yes"
        openUrl(str)
    }

    func gotoGoogleMaps(latitude: Double, longitude: Double) {
        let str = "comgooglemaps://?saddr=&daddr=\(latitude)),\(longitude)&directionsmode=driving"
        openUrl(str)
    }

    func gotoMaps(latitude: Double, longitude: Double) {
        let geoCoder = CLGeocoder()
        let locatoin = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(locatoin) { (placemarks, error) in
            if error != nil {
                self.logger.error("Não foi possível carregar a localização")
            }
            if let placemark = placemarks?.first {
                if let address = placemark.name {
                    let str = "http://maps.apple.com/?daddr=\(address)&dirflg=d"
                    self.openUrl(str.replacingOccurrences(of: " ", with: "+"))
                }
            }
        }
    }
}
