//
//  MapInfoOverlayView.swift
//  CAD
//
//  Created by Samir Chaves on 14/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import Location

class MapInfoOverlayView: UIView {
    enum MapInfoOverlayState {
        case deny, notDetermined, noActiveTeam, allowed
    }

    private let blurView: UIView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        return view.enableAutoLayout()
    }()

    var state: MapInfoOverlayState = .deny {
        didSet {
            switch state {
            case .deny:
                iconView.image = UIImage(named: "directionIcon")
                titleLabel.text = "Habilite sua localização"
                descriptionLabel.text = "Para receber empenhos da Central de Despachos de maneira mais precisa e eficiente, acesse as configurações do seu aparelho para permitir o acesso a sua localização sempre."
                button.setTitle("Ir para as Configurações", for: .normal)
                button.removeTarget(nil, action: nil, for: .allEvents)
                button.addTarget(self, action: #selector(gotoSettings), for: .touchUpInside)
                button.isHidden = false
            case .notDetermined:
                iconView.image = UIImage(named: "directionIcon")
                titleLabel.text = "Habilite sua localização"
                descriptionLabel.text = "Este aplicativo requer que os serviços da sua localização estejam ativados no seu aparelho e no app.  Esta ação ajudará a central de despachos a encaminhar empenhos de maneira mais eficiente."
                button.setTitle("Habilitar localização", for: .normal)
                button.removeTarget(nil, action: nil, for: .allEvents)
                button.addTarget(self, action: #selector(requestUserLocation), for: .touchUpInside)
                button.isHidden = false
            case .noActiveTeam:
                iconView.image = UIImage(named: "equipe")
                titleLabel.text = "Parace que você não está em uma equipe ativa no momento."
                descriptionLabel.text = "Não se preocupe, assim que estiver em uma equipe ativa o modulo do Tempo Real será ativado automaticamente."
                button.isHidden = true
            case .allowed:
                isHidden = true
            }
        }
    }

    private var locationService = LocationService.shared

    let button = AGCRoundedButton(text: "Habilitar localização")
        .height(40).width(190).enableAutoLayout()

    let iconView = UIImageView(
        image: UIImage(named: "directionIcon")
    ).enableAutoLayout()

    let titleLabel = UILabel().font(UIFont.robotoMedium.withSize(17))
        .color(.appCellLabel)
        .lines(0).enableAutoLayout()

    let descriptionLabel = UILabel().font(UIFont.robotoMedium.withSize(14))
        .color(UIColor.appCellLabel.withAlphaComponent(0.7))
        .lines(0).enableAutoLayout()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(blurView)

        blurView.fillSuperView(regardSafeArea: false)
        addSubviews()
    }

    @objc private func requestUserLocation() {
        locationService.requestUserLocation()
    }

    func addSubviews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(iconView)
        addSubview(button)
        titleLabel.textAlignment = .center
        descriptionLabel.textAlignment = .center

        iconView.centerX().width(140).height(140)
        titleLabel.centerX().centerY().width(widthAnchor, multiplier: 0.85).top(to: iconView.bottomAnchor, mutiplier: 3)
        descriptionLabel.centerX().width(widthAnchor, multiplier: 0.85).top(to: titleLabel.bottomAnchor, mutiplier: 2)
        button.centerX().top(to: descriptionLabel.bottomAnchor, mutiplier: 3)
        button.isHidden = true
    }

    @objc func gotoSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        let app = UIApplication.shared
        if app.canOpenURL(url) {
            app.open(url, options: [:], completionHandler: nil)
        }
    }
}
