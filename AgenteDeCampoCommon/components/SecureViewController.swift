//
//  SecureViewController.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 18/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

/**
    The view of this UIViewController could not contain an UINavigationController view as it subview.
 */
open class SecureViewController: UIViewController {
    private var secured = false

    private let blockingView: UITextField = {
        let view = UITextField()
        view.isSecureTextEntry = true
        return view
    }()

    private func makeSecure() {
        if !secured {
            DispatchQueue.main.async {
                self.secured = true
                self.blockingView.isSecureTextEntry = true
                self.view.addSubview(self.blockingView)
                if let superlayer = self.view.layer.superlayer,
                   let sublayers = superlayer.sublayers,
                   let layerIndex = sublayers.firstIndex(of: self.view.layer) {
                    superlayer.addSublayer(self.blockingView.layer)
                    let frontLayers = Array(sublayers[(layerIndex + 1)..<sublayers.count])
                    frontLayers.forEach { layer in
                        layer.removeFromSuperlayer()
                        superlayer.addSublayer(layer)
                    }
                }
                self.blockingView.layer.sublayers?.first?.addSublayer(self.view.layer)
            }
        }
    }

    private func enableSecurity() {
        DispatchQueue.main.async {
            self.blockingView.isSecureTextEntry = true
        }
    }

    private func disableSecurity() {
        DispatchQueue.main.async {
            self.blockingView.isSecureTextEntry = false
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
//        if ACEnviroment.shared.securityEnv == .production {
//            makeSecure()
//            let center = NotificationCenter.default
//            center.addObserver(self, selector: #selector(willBecomeInactive(_:)), name: UIScene.willDeactivateNotification, object: nil)
//            center.addObserver(self, selector: #selector(didBecomeActive(_:)), name: UIScene.didActivateNotification, object: nil)
//        }
    }

    @objc private func willBecomeInactive(_ notification: Notification) {
        disableSecurity()
    }

    @objc private func didBecomeActive(_ notification: Notification) {
        enableSecurity()
    }
}
