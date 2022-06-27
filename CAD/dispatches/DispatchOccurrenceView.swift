//
//  DispatchOccurrenceView.swift
//  CAD
//
//  Created by Samir Chaves on 01/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import MarqueeLabel
import AgenteDeCampoCommon
import MapKit
import Location
import UIKit

extension NSAttributedString.Key {
    static let token = NSAttributedString.Key("Token")

}

final class TokenLayoutManager: NSLayoutManager {
    var textContainerOriginOffset: CGSize = .zero

    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        textStorage?.enumerateAttribute(.token, in: characterRange, options: .longestEffectiveRangeNotRequired, using: { (value, subrange, _) in
            guard let token = value as? String, !token.isEmpty else { return }
            let tokenGlypeRange = glyphRange(forCharacterRange: subrange, actualCharacterRange: nil)
            drawToken(forGlyphRange: tokenGlypeRange)
        })
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
    }

    private func drawToken(forGlyphRange tokenGlypeRange: NSRange) {
        guard let textContainer = textContainer(forGlyphAt: tokenGlypeRange.location, effectiveRange: nil) else { return }
        let withinRange = NSRange(location: NSNotFound, length: 0)
        enumerateEnclosingRects(forGlyphRange: tokenGlypeRange, withinSelectedGlyphRange: withinRange, in: textContainer) { (rect, _) in
            let tokenRect = rect.offsetBy(dx: self.textContainerOriginOffset.width, dy: self.textContainerOriginOffset.height)
            UIColor.appBlue.setFill()
            UIBezierPath(roundedRect: tokenRect, cornerRadius: 4).fill()
        }
    }
}

class DispatchOccurrenceView: UIView {
    private var priorityLabel = OccurrencePriorityLabel()
    public let locationService = LocationService.shared
    private let timeLabel = UILabel.build(withSize: 13, color: .appTitle)
    
    private let addressLabel: MarqueeLabel = {
        let label = MarqueeLabel(text: "")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .appTitle
        return label.enableAutoLayout()
    }()
    private let naturesLabel: MarqueeLabel = {
        let label = MarqueeLabel(text: "")
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .appTitle
        label.type = .left
        return label.enableAutoLayout()
    }()
    private let distanceLabel: UILabel = {
        let label = UILabel.build(withSize: 12, alpha: 0.6, color: .appTitle)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.backgroundColor = UIColor.appTitle.withAlphaComponent(0.2)
        return label
    }()
    private let travelTimeLabel: UILabel = {
        let label = UILabel.build(withSize: 12, alpha: 0.6, color: .appTitle)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.backgroundColor = UIColor.appTitle.withAlphaComponent(0.2)
        return label
    }()

    private func simpleHumanize(diff: DateComponents) -> String {
        if let year = diff.year, year > 0 {
            let text = diff.getComponentText(year, for: .year, shortText: false)
            return "\(year) \(text)"
        }

        if let month = diff.month, month > 0 {
            let text = diff.getComponentText(month, for: .month, shortText: false)
            return "\(month) \(text)"
        }

        if let day = diff.day, day > 0 {
            let text = diff.getComponentText(day, for: .day, shortText: false)
            return "\(day) \(text)"
        }

        if let hour = diff.hour, hour > 0 {
            let text = diff.getComponentText(hour, for: .hour, shortText: true)
            return "\(hour) \(text)"
        }

        if let minute = diff.minute, minute > 0 {
            let text = diff.getComponentText(minute, for: .minute, shortText: true)
            return "\(minute) \(text)"
        }

        return "Agora"
    }

    func configure(with occurrence: OccurrenceDetails, dispatch: Dispatch) {
        _ = priorityLabel.withPriority(occurrence.generalInfo.priority, maxWidth: 75)
        let naturesTexts = occurrence.natures.map { NSAttributedString(string: $0.name) }
        let finalText = NSMutableAttributedString()
        naturesTexts.enumerated().forEach { (index, piece) in
            finalText.append(piece)
            if index < naturesTexts.count - 1 {
                finalText.append(NSAttributedString(string: " • ", attributes: [.foregroundColor: UIColor.appTitle.withAlphaComponent(0.6)]))
            }
        }
        naturesLabel.attributedText = finalText

        let address = occurrence.address

        addressLabel.text = "\(address.getFormattedAddress())       "
        
        let dispatchDateTime = DateTimeWithTimeZone(dateTime: dispatch.dateTime, timeZone: dispatch.timeZone)
        let serviceRegisterDiff = dispatchDateTime.toDate(format: "yyyy-MM-dd'T'HH:mm:ss")?.convertToUTC()?
            .difference(to: Date(), [.year, .month, .day, .hour, .minute])
        timeLabel.text = serviceRegisterDiff.map { self.simpleHumanize(diff: $0) }

        loadTravelData(address: occurrence.address)
    }

    private func loadTravelData(address: Location) {
        if let userCoordinates = locationService.currentLocation?.coordinate,
           let occurrenceCoordinates = address.coordinates {
            travelTimeLabel.text = "            "
            distanceLabel.text = "            "
            travelTimeLabel.backgroundColor = UIColor.appTitle.withAlphaComponent(0.3)
            distanceLabel.backgroundColor = UIColor.appTitle.withAlphaComponent(0.3)

            let directionRequest = MKDirections.Request()
            directionRequest.source = MKMapItem(
                placemark: MKPlacemark(
                    coordinate: userCoordinates
                )
            )
            directionRequest.destination = MKMapItem(
                placemark: MKPlacemark(
                    coordinate: CLLocationCoordinate2D(
                        latitude: occurrenceCoordinates.latitude,
                        longitude: occurrenceCoordinates.longitude
                    )
                )
            )
            directionRequest.transportType = .automobile
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, _) in
                guard let response = response else { return }
                guard let route = response.routes.first else { return }
                let travelTime = Int(route.expectedTravelTime / 60)
                if travelTime > 60 {
                    self.travelTimeLabel.text = "\(Int(travelTime / 60)) h"
                } else {
                    self.travelTimeLabel.text = "\(travelTime) min"
                }

                if route.distance < 1000 {
                    self.distanceLabel.text = "\(Int(route.distance)) m"
                } else {
                    self.distanceLabel.text = String(format: "%.1f km", route.distance / 1000)
                }
                self.travelTimeLabel.backgroundColor = .clear
                self.distanceLabel.backgroundColor = .clear
            }

        }
    }

    override func didMoveToSuperview() {
        addSubview(timeLabel)
        addSubview(priorityLabel)
        addSubview(addressLabel)
        addSubview(distanceLabel)
        addSubview(travelTimeLabel)
        addSubview(naturesLabel)

        NSLayoutConstraint.activate([
            priorityLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            priorityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),

            timeLabel.centerXAnchor.constraint(equalTo: priorityLabel.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: 5),

            addressLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            addressLabel.leadingAnchor.constraint(equalTo: priorityLabel.trailingAnchor, constant: 10),
            addressLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            travelTimeLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 3),
            travelTimeLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),

            distanceLabel.centerYAnchor.constraint(equalTo: travelTimeLabel.centerYAnchor),
            distanceLabel.leadingAnchor.constraint(equalTo: travelTimeLabel.trailingAnchor, constant: 15),

            naturesLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 3),
            naturesLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            naturesLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
