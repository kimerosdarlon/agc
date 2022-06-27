//
//  PinDetail.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class PinDetail: UIView {

    private let image: UIImageView = {
        let view = UIImageView()
        view.enableAutoLayout()
        view.image = UIImage(named: "semafaro")
        view.height(45).width(25)
        view.contentMode = .scaleAspectFit
        return view
    }()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoMedium.withSize(16)
        label.textColor = .appTitle
        label.numberOfLines = 0
        return label
    }()

    private let positionLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoMedium.withSize(12)
        label.textColor = .appTitle
        label.text = "1"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let positionView: UIView = {
        let view = UIView()
        view.enableAutoLayout()
        view.height(20).width(20)
        view.layer.cornerRadius = 10
        view.backgroundColor = .appRed
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    private let dateLb: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoMedium.withSize(14)
        label.textColor = .appTitle
        label.numberOfLines = 2
        return label
    }()

    private let timeLb: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoMedium.withSize(14)
        label.textColor = .appTitle
        label.numberOfLines = 2
        return label
    }()

    private let marginBotton: CGFloat

    init(location: VehicleLocation? = nil, marginBotton: CGFloat = 1) {
        self.marginBotton = marginBotton
        super.init(frame: .zero)
        guard let location = location else { return }
        configure(with: location)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with location: VehicleLocation) {
        locationLabel.text = location.local
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        if let date = formatter.date(from: location.moment) {
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "dd/MM/yyyy"
            dateLb.text = "Dia\n"+formatter.string(from: date)
            formatter.dateFormat = "HH:mm:ss"
            timeLb.text = "Hora\n" + formatter.string(from: date)
        }
    }

    override func layoutSubviews() {
        addSubview(image)
        addSubview(locationLabel)
        addSubview(dateLb)
        addSubview(timeLb)
        positionView.addSubview(positionLabel)
        positionLabel.fillSuperView()
        addSubview(positionView)
        let dateTop = dateLb.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: locationLabel.bottomAnchor, multiplier: 1)
        dateTop.priority = .defaultLow
        let height = locationLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 22)
        height.priority = .required
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            image.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),

            positionView.topAnchor.constraint(equalToSystemSpacingBelow: image.bottomAnchor, multiplier: 1),
            positionView.centerXAnchor.constraint(equalTo: image.centerXAnchor),
            bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: positionView.bottomAnchor, multiplier: 1),
            locationLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: image.trailingAnchor, multiplier: 1),
            locationLabel.topAnchor.constraint(equalTo: image.topAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: locationLabel.trailingAnchor, multiplier: 1),
            dateTop,
            height,
            dateLb.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: locationLabel.bottomAnchor, multiplier: 1),
            dateLb.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor),
            bottomAnchor.constraint(equalToSystemSpacingBelow: dateLb.bottomAnchor, multiplier: marginBotton),

            timeLb.leadingAnchor.constraint(equalToSystemSpacingAfter: dateLb.trailingAnchor, multiplier: 1),
            timeLb.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: locationLabel.bottomAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: timeLb.bottomAnchor, multiplier: marginBotton)
        ])
    }

    func setPosition(_ position: Int) {
        positionLabel.text = "\(position)"
        positionView.isHidden = false
        positionLabel.isHidden = false
    }
}
