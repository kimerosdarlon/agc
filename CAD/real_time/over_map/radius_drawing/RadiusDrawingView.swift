//
//  RadiusDrawingView.swift
//  CAD
//
//  Created by Samir Chaves on 29/04/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import MapKit

class RadiusDrawingView: UntouchableView {
    weak var navigation: OverMapNavigation?
    private var mapView: RealTimeMapView!
    private var parentViewController: UIViewController
    private var initialRadius: CGFloat?
    private var initialLocation: CLLocationCoordinate2D?
    private var maxRadius: CGFloat = 50000
    private let dataSource: RecentOccurrencesDataSource
    private let radiusSlider = RadiusSliderView().enableAutoLayout()
    private let tipImage: UIImageView = {
        let image = UIImage(named: "clickingLight")
        let view = UIImageView(image: image)
        view.width(19).height(25)
        return view.enableAutoLayout()
    }()
    private let tipLabelContainer: UIView = {
        let view = UIView(frame: .zero).enableAutoLayout()
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    private let tipLabel = UILabel.build(withSize: 15, color: .appTitle, text: "Toque no local desejado para reposicionar o raio")
    private let header = RadiusDrawingHeaderView().enableAutoLayout()

    init(mapView: RealTimeMapView, dataSource: RecentOccurrencesDataSource, parentViewController: UIViewController) {
        self.mapView = mapView
        self.parentViewController = parentViewController
        self.dataSource = dataSource
        super.init(frame: .zero)
        header.delegate = self
        radiusSlider.delegate = self
    }

    func setInitialCircle(initialRadius: CGFloat, initialLocation: CLLocationCoordinate2D) {
        self.initialRadius = initialRadius
        self.initialLocation = initialLocation

        mapView.updateCircle(radius: initialRadius, location: initialLocation)

        radiusSlider.minimumValue = 100
        let maximumValue = round(initialRadius * 2 / 100) * 100
        radiusSlider.maximumValue = maximumValue > maxRadius ? maxRadius : maximumValue
        if (radiusSlider.maximumValue - radiusSlider.minimumValue) <= 200 {
            radiusSlider.valueStep = 10
        } else if (radiusSlider.maximumValue - radiusSlider.minimumValue) >= 10000 {
            radiusSlider.valueStep = 1000
        } else {
            radiusSlider.valueStep = 100
        }
        radiusSlider.radius = initialRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        addSubview(header)
        addSubview(radiusSlider)
        addSubview(tipLabelContainer)
        
        tipLabelContainer.addSubview(tipImage)
        tipLabelContainer.addSubview(tipLabel)

        header.height(60)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),

            tipLabelContainer.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            tipLabelContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            tipLabelContainer.bottomAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: 10),

            tipLabel.topAnchor.constraint(equalTo: tipLabelContainer.topAnchor, constant: 10),
            tipLabel.leadingAnchor.constraint(equalTo: tipImage.trailingAnchor, constant: 10),
            tipLabel.trailingAnchor.constraint(lessThanOrEqualTo: tipLabelContainer.trailingAnchor, constant: -10),

            tipImage.centerYAnchor.constraint(equalTo: tipLabelContainer.centerYAnchor),
            tipImage.leadingAnchor.constraint(equalTo: tipLabelContainer.leadingAnchor, constant: 10),

            radiusSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            radiusSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            radiusSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }
}

extension RadiusDrawingView: RadiusDrawingHeaderDelegate, RadiusSliderDelegate {
    func didCancel() {
        if let initialRadius = self.initialRadius,
           let initialLocation = self.initialLocation {
            mapView.updateCircle(radius: initialRadius, location: initialLocation)
        }
        navigation?.goToHome()
        mapView.endEditingRadius()
    }

    func didFinish() {
        mapView.endEditingRadius()
        navigation?.goToHome()
        dataSource.fetchRecentOccurrences(
            location: mapView.getCirclePosition(),
            radius: mapView.getCircleRadius()
        ) { error in
            garanteeMainThread {
                if let error = error as NSError?, self.parentViewController.isUnauthorized(error) {
                    self.parentViewController.gotoLogin(error.domain)
                }
            }
        }
    }

    func radiusDidSelect(_ radius: CGFloat) {
        mapView.updateCircle(radius: radius)
    }
}
