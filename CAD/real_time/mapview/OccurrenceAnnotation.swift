//
//  CustomAnnotation.swift
//  CAD
//
//  Created by Samir Chaves on 10/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import MapKit
import AgenteDeCampoCommon
import UIKit

class OccurrenceAnnotation: MKPointAnnotation {
    var occurrence: SimpleOccurrence
    init(occurrence: SimpleOccurrence) {
        self.occurrence = occurrence
        super.init()
    }
}

class OccurrenceAnnotationView: MKAnnotationView {
    static let identifier = "OccurrenceAnnotation"
    private static let pinSize: CGFloat = 19
    private static let frameWidth: CGFloat = 130
    private static let frameHeight: CGFloat = 50

    private let iconProvider = OccurrenceIconProvider.shared

    private let label: UILabel = {
        let frameWidth = OccurrenceAnnotationView.frameWidth
        let frameHeight = OccurrenceAnnotationView.frameHeight
        let pinSize = OccurrenceAnnotationView.pinSize
        let label = UILabel.build(withSize: 10, weight: .bold, alignment: .center)
        label.frame = .init(x: 0, y: pinSize, width: frameWidth, height: 30)
        label.numberOfLines = 2
        label.contentMode = .top
        label.translatesAutoresizingMaskIntoConstraints = true
        label.isHidden = true
        return label
    }()

    private let icon = UIImageView(frame: .init(x: 3.5, y: 3.5, width: pinSize - 7, height: pinSize - 7))

    private let pin: UIView = {
        let frameWidth = OccurrenceAnnotationView.frameWidth
        let frameHeight = OccurrenceAnnotationView.frameHeight
        let pinSize = OccurrenceAnnotationView.pinSize
        let view = UIView(frame: .init(x: frameWidth / 2 - pinSize / 2, y: 0, width: pinSize, height: pinSize))
        view.layer.cornerRadius = pinSize / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor.copy(alpha: 0.4)
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 15
        view.layer.shadowOpacity = 1
        return view
    }()

    private let pinPulse: UIView = {
        let frameWidth = OccurrenceAnnotationView.frameWidth
        let frameHeight = OccurrenceAnnotationView.frameHeight
        let pinSize = OccurrenceAnnotationView.pinSize
        let view = UIView(frame: .init(x: frameWidth / 2 - pinSize / 2, y: 0, width: pinSize, height: pinSize))
        view.layer.cornerRadius = pinSize / 2
        view.alpha = 0.7
        return view
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(label)
        addSubview(pinPulse)
        addSubview(pin)
        icon.alpha = 0.6
        pin.addSubview(icon)
        hideLabel()

        if superview != nil {
            pin.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
            hideLabel()

            UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
                self.pin.transform = CGAffineTransform.identity
            }
        }
    }

    func hide() {
        self.pin.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
    }

    func hideLabel() {
        label.fadeOut()
    }

    func showLabel() {
        label.fadeIn()
    }

    override var annotation: MKAnnotation? {
      willSet {
        guard let occurrence = newValue as? OccurrenceAnnotation else {
          return
        }
        configure(withAnnotation: occurrence)
      }
    }

    private func configure(withAnnotation annotation: OccurrenceAnnotation) {
        var color = UIColor.appRed
        let occurrence = annotation.occurrence

        switch occurrence.priority {
        case .low:
            color = UIColor(red: 0, green: 189 / 255, blue: 214 / 255, alpha: 1)
        case .medium:
            color = UIColor(red: 255 / 255, green: 216 / 255, blue: 0, alpha: 1)
        case .high:
            color = UIColor(red: 255 / 255, green: 85 / 255, blue: 98 / 255, alpha: 1)
        case .redAlert:
            color = UIColor(red: 255 / 255, green: 37 / 255, blue: 0, alpha: 1)
        }

        label.textColor = color
        label.attributedText = NSAttributedString(string: annotation.title ?? "", attributes: [
            .foregroundColor: color,
            .strokeWidth: -2,
            .strokeColor: UIColor.appTitle
        ])

        let natureIcon = (occurrence.natures.first?.name).flatMap { natureName in
            iconProvider.getIcon(for: natureName)
        }
        icon.image = natureIcon

        let frameWidth = OccurrenceAnnotationView.frameWidth
        let frameHeight = OccurrenceAnnotationView.frameHeight
        frame = .init(x: 0, y: 0, width: frameWidth, height: frameHeight)
        centerOffset = .init(x: 0, y: frameHeight / 2)
        image = nil
        pin.backgroundColor = color
        collisionMode = .rectangle
        pin.layer.shadowColor = color.cgColor.copy(alpha: 0.6)
        canShowCallout = false

        self.pinPulse.transform = CGAffineTransform.identity
        self.pinPulse.alpha = 0.7

        if !self.pinPulse.isAnimating {
            // Pulse animation
            let timingFunction = CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1) // easeOutCubic
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(timingFunction)
            UIView.animate(withDuration: 2, delay: 0, options: [.repeat]) {
                self.pinPulse.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 3)
                self.pinPulse.alpha = 0
            }
            CATransaction.commit()
        }

        if occurrence.generalAlert {
            pinPulse.backgroundColor = color
        } else {
            pinPulse.backgroundColor = .clear
        }
    }
}
