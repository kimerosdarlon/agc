//
//  UIViewController+AgenteCampo.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 07/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

public extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if let navigationController = navigationController, navigationController.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if let tabBarController = tabBarController, tabBarController.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }

    func openMaps(from origin: CLLocationCoordinate2D?, to destination: CLLocationCoordinate2D, withTitle title: String = "") {
        let application = UIApplication.shared
        let coordinate = "\(String(destination.latitude)),\(String(destination.longitude))"
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        var handlers = [(String, String)]()
        if let currentLocation = origin {
            let coordinates = [currentLocation.latitude, currentLocation.longitude]
            let origin = coordinates.map { String($0) }.joined(separator: ",")
            handlers = [
                ("Apple Maps", "http://maps.apple.com/?q=\(encodedTitle)&ll=\(coordinate)"),
                ("Google Maps", "https://www.google.com/maps/dir/?api=1&origin=\(origin)&destination=\(coordinate)"),
                ("Waze", "waze://?ll=\(coordinate)&navigate=yes")
            ]
        } else {
            handlers = [
                ("Apple Maps", "http://maps.apple.com/?q=\(encodedTitle)&ll=\(coordinate)"),
                ("Google Maps", "https://www.google.com/maps/search/?api=1&query=\(coordinate)"),
                ("Waze", "waze://?ll=\(coordinate)")
            ]
        }

        let availableHandlers = handlers.compactMap { (name, address) in URL(string: address).map { (name, $0) } }
                            .filter { (_, url) in application.canOpenURL(url) }

        guard availableHandlers.count > 1 else {
            if let (_, url) = availableHandlers.first {
                application.open(url, options: [:])
            }
            return
        }
        let alert = UIAlertController(title: "Selecione o aplicativo", message: nil, preferredStyle: .actionSheet)
        availableHandlers.forEach { (name, url) in
            alert.addAction(UIAlertAction(title: name, style: .default) { _ in
                application.open(url, options: [:])
            })
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
}
