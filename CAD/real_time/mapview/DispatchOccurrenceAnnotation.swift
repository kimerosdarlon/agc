//
//  File.swift
//  CAD
//
//  Created by Samir Chaves on 06/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DispatchOccurrenceAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)

    var title: String?
    var subtitle: String?

    enum PresentationState {
        case equipment, member
    }
    var presentationState: PresentationState = .equipment

    var occurrence: OccurrenceDetails

    init(occurrence: OccurrenceDetails) {
        self.occurrence = occurrence
        if let latitude = occurrence.address.coordinates?.latitude,
           let longitude = occurrence.address.coordinates?.longitude {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        super.init()
    }

    func updatePosition(_ position: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.3) {
            self.coordinate = position
        }
    }
}

class DispatchOccurrenceAnnotationView: MKAnnotationView {
    static let identifier = "DispatchOccurrenceAnnotation"
    private static let pinSize: CGFloat = 25

    internal var arrow: AnnotationArrow
    internal var arrowBorder: AnnotationArrow

    internal let pin: UIView = {
        let pinSize: CGFloat = DispatchOccurrenceAnnotationView.pinSize
        let view = UIView(frame: .init(x: -pinSize / 2, y: -pinSize / 2, width: pinSize, height: pinSize))
        view.layer.cornerRadius = pinSize / 2
        view.layer.borderWidth = 4
        view.clipsToBounds = true
        return view
    }()

    internal let pinImage: UIImageView = {
        let size = pinSize * 0.85
        let view = UIImageView(frame: .init(x: -size / 2, y: -size / 2, width: size, height: size))
        view.image = MemberViewModel.defaultImage
        view.layer.cornerRadius = size / 2
        view.clipsToBounds = true
        return view
    }()

    internal let pinBorder: UIView = {
        let pinSize: CGFloat = DispatchOccurrenceAnnotationView.pinSize + 2
        let view = UIView(frame: .init(x: -pinSize / 2, y: -pinSize / 2, width: pinSize, height: pinSize))
        view.layer.cornerRadius = pinSize / 2
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private let pinPulse: UIView = {
        let view = UIView(frame: .init(x: -pinSize / 2, y: pinSize / 2, width: pinSize, height: pinSize))
        view.layer.cornerRadius = pinSize / 2
        view.alpha = 0.7
        view.backgroundColor = .appBlue
        return view
    }()

    private let titleLabel = UILabel.build(withSize: 9, alpha: 1, weight: .bold, color: .appTitle, alignment: .center)
    private let subtitleLabel = UILabel.build(withSize: 8, alpha: 0.9, weight: .bold, color: .appTitle, alignment: .center)
    private let labelsContainer = UIView(frame: .zero).enableAutoLayout()

    private let iconProvider = OccurrenceIconProvider.shared

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        arrow = AnnotationArrow(
            frame: .init(x: -10, y: 8, width: 20, height: 13),
            color: CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        )
        arrowBorder = AnnotationArrow(
            frame: .init(x: -11, y: 8, width: 22, height: 15),
            color: CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        )
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        pin.layer.borderColor = CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        pin.backgroundColor = .gray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        addSubview(pinPulse)
        addSubview(pinBorder)
        addSubview(arrowBorder)
        addSubview(arrow)
        addSubview(pin)
        addSubview(labelsContainer)
        addSubview(pinImage)
        labelsContainer.addSubview(titleLabel)
        labelsContainer.addSubview(subtitleLabel)
        labelsContainer.isHidden = true
        collisionMode = .circle

        transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: DispatchOccurrenceAnnotationView.pinSize)
            .scaledBy(x: 0, y: 0)

        UIView.animate(withDuration: 0.4, delay: 0.2) {
            self.transform = CGAffineTransform.identity
        }

        labelsContainer.centerX().width(100)
        titleLabel.centerX().width(100)
        subtitleLabel.centerX().width(100)
        NSLayoutConstraint.activate([
            labelsContainer.topAnchor.constraint(equalTo: arrow.bottomAnchor, constant: 7.5),
            titleLabel.topAnchor.constraint(equalTo: labelsContainer.topAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            labelsContainer.bottomAnchor.constraint(equalTo: subtitleLabel.bottomAnchor)
        ])
    }

    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? DispatchOccurrenceAnnotation else {
              return
            }
            configure(with: annotation)
        }
    }

    func configure(with annotation: DispatchOccurrenceAnnotation) {
        image = nil
        canShowCallout = false
        let pinSize: CGFloat = DispatchOccurrenceAnnotationView.pinSize
        centerOffset = .init(x: 0, y: -pinSize)

        var color = UIColor.appRed
        let occurrence = annotation.occurrence

        switch occurrence.generalInfo.priority {
        case .low:
            color = UIColor(red: 0, green: 189 / 255, blue: 214 / 255, alpha: 1)
        case .medium:
            color = UIColor(red: 255 / 255, green: 216 / 255, blue: 0, alpha: 1)
        case .high:
            color = UIColor(red: 255 / 255, green: 85 / 255, blue: 98 / 255, alpha: 1)
        case .redAlert:
            color = UIColor(red: 255 / 255, green: 37 / 255, blue: 0, alpha: 1)
        }
        arrow.color = color.cgColor
        arrow.didMoveToSuperview()
        pin.backgroundColor = color

        let natureIcon = (occurrence.natures.first?.name).flatMap { natureName in
            iconProvider.getIcon(for: natureName)
        }
        pinImage.image = natureIcon
        pin.layer.borderColor = color.cgColor

        pinPulse.backgroundColor = color

        if occurrence.generalInfo.generalAlert {
            pinPulse.alpha = 0.7
            pinPulse.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.005)

            if !self.pinPulse.isAnimating {
                // Pulse animation
                let timingFunction = CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1) // easeOutCubic
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(timingFunction)
                UIView.animate(withDuration: 2, delay: 0, options: [.repeat]) {
                    self.pinPulse.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 1.5)
                    self.pinPulse.alpha = 0
                }
                CATransaction.commit()
            }
            pinPulse.backgroundColor = color
        } else {
            pinPulse.alpha = 0.7
            pinPulse.transform = CGAffineTransform.identity.scaledBy(x: 1.6, y: 0.8)
            pinPulse.backgroundColor = .clear
            pinPulse.layer.borderWidth = 1
            pinPulse.layer.borderColor = UIColor.appTitle.cgColor
        }
    }

    func hideLabel() {
        labelsContainer.fadeOut()
    }

    func showLabel() {
        labelsContainer.fadeIn()
    }
}
