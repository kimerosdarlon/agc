//
//  AnnotationArrow.swift
//  CAD
//
//  Created by Samir Chaves on 13/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AnnotationArrow: UIView {
    var color: CGColor

    init(frame: CGRect, color: CGColor) {
        self.color = color
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        self.color = CGColor(gray: 0.8, alpha: 1)
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()

        context.setFillColor(self.color)
        context.fillPath()
        transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
    }

    override func didMoveToSuperview() {
        backgroundColor = .clear
    }
}
