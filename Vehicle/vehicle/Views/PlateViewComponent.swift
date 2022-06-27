//
//  PlateViewComponent.swift
//  Vehicle
//
//  Created by Ramires Moreira on 06/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class PlateViewComponent: UIView {
    private var actionBuilder: ActionBuilder?
    weak var warningDelegate: PlateViewWarningDelegate?
    private var conversionAlert: String?

    let plateLabel = UILabel()
    private lazy var plateView: UIView = {
        let view = UIView()
        let topView = UIView()
        plateLabel.font = UIFont.robotoMedium.withSize(14)
        plateLabel.textColor = .appBlack
        view.addSubview(plateLabel)
        view.addSubview(topView)
        topView.enableAutoLayout()
        plateLabel.enableAutoLayout()
        view.enableAutoLayout()
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 9),
            plateLabel.topAnchor.constraint(equalTo: topView.bottomAnchor),
            plateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            plateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            plateLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        topView.backgroundColor = .appBlue
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        self.plateLabel.textAlignment = .center
        self.plateLabel.backgroundColor = .white
        return view
    }()

    private var vehicleInfo: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoBold.withSize(16)
        label.textColor = .appCellLabel
        label.enableAutoLayout()
        return label
    }()

    public func didWarningVisibilityChanged(_ isVisible: Bool) {
        if isVisible {
            UIView.animate(withDuration: 0.2) {
                self.warningMessageIcon.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.warningMessageIcon.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }

    @objc func warningTapped(_ sender: UITapGestureRecognizer) {
        warningDelegate?.toggleWarningMessage()
    }

    private var hasInfo = false

    init(plate: String = "") {
        super.init(frame: .zero)
        enableAutoLayout()
        set(plate: plate)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(plateView)

        if hasInfo {
            addSubview(vehicleInfo)
            if conversionAlert != nil {
                addSubview(warningMessageIcon)
                NSLayoutConstraint.activate([
                    warningMessageIcon.trailingAnchor.constraint(equalTo: vehicleInfo.leadingAnchor, constant: -10),
                    warningMessageIcon.centerYAnchor.constraint(equalTo: vehicleInfo.centerYAnchor)
                ])
            }

            NSLayoutConstraint.activate([
                plateView.topAnchor.constraint(equalTo: topAnchor),
                plateView.centerXAnchor.constraint(equalTo: centerXAnchor),
                plateView.widthAnchor.constraint(equalToConstant: 150),
                vehicleInfo.topAnchor.constraint(equalToSystemSpacingBelow: plateView.bottomAnchor, multiplier: 1),
                vehicleInfo.centerXAnchor.constraint(equalTo: centerXAnchor),
                vehicleInfo.heightAnchor.constraint(equalToConstant: 33),
                bottomAnchor.constraint(equalTo: vehicleInfo.bottomAnchor)
            ])
        } else {
            plateView.fillSuperView()
        }
        actionBuilder = ActionBuilder(text: plateLabel.text ?? "")
        let interaction = UIContextMenuInteraction(delegate: actionBuilder!)
        plateView.addInteraction(interaction)
    }

    func set(vehicle: VehicleDetailViewModel) {
        hasInfo = true
        let plate = vehicle.plate
        vehicleInfo.text = vehicle.title
        set(plate: plate)
        if let conversionAlert = vehicle.conversionAlert {
            self.conversionAlert = conversionAlert
            let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.warningTapped(_:)))
            warningMessageIcon.isUserInteractionEnabled = true
            warningMessageIcon.addGestureRecognizer(labelTap)
        }
    }

    func set(plate: String) {
        if plate.matches(in: "\\w{3}\\d{4}") {
            plateLabel.text = plate.apply(pattern: "### - ####", replacmentCharacter: "#")
        } else {
            plateLabel.text = plate
        }
    }

    private var warningMessageIcon: UIImageView = {
        let image = UIImage(systemName: "exclamationmark.circle.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let view = UIImageView(image: image)
        view.enableAutoLayout()
        view.contentMode = .scaleAspectFit
        return view
    }()

    func setFontStyle(_ style: FontStyle) {
        DispatchQueue.main.async {
            switch style {
            case .large:
                self.plateLabel.font = UIFont.robotoMedium.withSize(22)
            default:
                self.plateLabel.font = UIFont.robotoMedium.withSize(14)
            }
        }

    }
}

enum FontStyle {
    case regular
    case light
    case large
}
