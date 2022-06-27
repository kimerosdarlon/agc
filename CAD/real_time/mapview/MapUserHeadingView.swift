//
//  MapUserHeadingView.swift
//  CAD
//
//  Created by Samir Chaves on 05/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapUserHeadingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let width = rect.maxX - rect.minX

        context.beginPath()
        context.move(to: CGPoint(x: (width / 3.0), y: rect.minY))
        context.addLine(to: CGPoint(x: 2 * (width / 3.0), y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.closePath()

        context.clip()

        let colors = [UIColor.appBlue.cgColor, UIColor.appBlue.cgColor.copy(alpha: 0)] as CFArray

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]

        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)

        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!

        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.fillPath()
        transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
    }

    override func didMoveToSuperview() {
        backgroundColor = .clear
    }
}
