//
//  RadiusSlider.swift
//  CAD
//
//  Created by Samir Chaves on 03/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

protocol TooltipedSliderPositionDelegate: class {
    func didChangeThumbPosition(_ rect: CGRect)
}

class TooltipedSlider: UISlider {
    weak var positionDelegate: TooltipedSliderPositionDelegate?

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let knobRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        positionDelegate?.didChangeThumbPosition(knobRect)
        return knobRect
    }
}

protocol RadiusSliderDelegate: class {
    func radiusDidSelect(_ radius: CGFloat)
}

class RadiusSliderView: UIView {
    weak var delegate: RadiusSliderDelegate?

    var valueStep: CGFloat = 100
    private let radiusSlider: TooltipedSlider = {
        let slider = TooltipedSlider(frame: .zero)
        return slider.enableAutoLayout()
    }()
    private let radiusSliderContainer: UIView = {
        let view = UIView().enableAutoLayout()
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    private let radiusLabel: PaddingLabel = {
        let label = PaddingLabel(withInsets: 10, 10, 10, 10)
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .appTitle
        label.backgroundColor = UIColor.appBackground.withAlphaComponent(0.7)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        return label.enableAutoLayout()
    }()
    private let minimumLabel = UILabel.build(withSize: 10, alpha: 0.8, weight: .bold, color: .appTitle)
    private let maximumLabel = UILabel.build(withSize: 10, alpha: 0.8, weight: .bold, color: .appTitle, alignment: .right)

    var radius: CGFloat = 0 {
        didSet {
            radiusSlider.setValue(Float(radius), animated: true)
            setRadiusText(radius)
        }
    }

    var minimumValue: CGFloat = 0 {
        didSet {
            minimumLabel.text = normalizeRadiusText(minimumValue)
            radiusSlider.minimumValue = Float(minimumValue)
        }
    }

    var maximumValue: CGFloat = 0 {
        didSet {
            maximumLabel.text = normalizeRadiusText(maximumValue)
            radiusSlider.maximumValue = Float(maximumValue)
        }
    }

    init() {
        super.init(frame: .zero)
        radiusSlider.positionDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func roundSliderValue(value: CGFloat) -> CGFloat {
        return round(value / valueStep) * valueStep
    }

    private func normalizeRadiusText(_ radius: CGFloat) -> String {
        var treatedRadius = radius < minimumValue ? minimumValue : radius
        treatedRadius = treatedRadius > maximumValue ? maximumValue : treatedRadius
        var unit = "m"
        var valueText = "\(Int(treatedRadius))"
        if treatedRadius >= 1000 {
            unit = "km"
            valueText = String(format: "%.1f", treatedRadius / 1000)
        }
        return "\(valueText) \(unit)"
    }

    private func setRadiusText(_ radius: CGFloat) {
        radiusLabel.text = normalizeRadiusText(radius)
    }

    @objc func radiusHasChanged(_ sender: UISlider) {
        let value = roundSliderValue(value: CGFloat(sender.value))
        radiusSlider.setValue(Float(value), animated: false)
        setRadiusText(value)
    }

    @objc func radiusWasSelected(_ sender: UISlider) {
        delegate?.radiusDidSelect(CGFloat(sender.value))
    }

    override func didMoveToSuperview() {
        addSubview(radiusSliderContainer)
        addSubview(radiusLabel)

        radiusSlider.isContinuous = true
        radiusSlider.addTarget(self, action: #selector(radiusHasChanged(_:)), for: .valueChanged)
        radiusSlider.addTarget(self, action: #selector(radiusWasSelected(_:)), for: .touchUpOutside)
        radiusSlider.addTarget(self, action: #selector(radiusWasSelected(_:)), for: .touchUpInside)

        radiusSliderContainer.addSubview(radiusSlider)
        radiusSliderContainer.addSubview(maximumLabel)
        radiusSliderContainer.addSubview(minimumLabel)

        radiusSliderContainer.height(60)
        radiusSlider.height(20)
        minimumLabel.width(50)
        maximumLabel.width(50)
        NSLayoutConstraint.activate([
            radiusLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            radiusLabel.bottomAnchor.constraint(equalTo: radiusSliderContainer.topAnchor, constant: -10),
            topAnchor.constraint(equalTo: radiusLabel.topAnchor),

            radiusSliderContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            radiusSliderContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            radiusSliderContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

            minimumLabel.topAnchor.constraint(equalTo: radiusSliderContainer.topAnchor, constant: 10),
            minimumLabel.leadingAnchor.constraint(equalTo: radiusSliderContainer.leadingAnchor, constant: 15),

            maximumLabel.topAnchor.constraint(equalTo: radiusSliderContainer.topAnchor, constant: 10),
            maximumLabel.trailingAnchor.constraint(equalTo: radiusSliderContainer.trailingAnchor, constant: -15),

            radiusSlider.bottomAnchor.constraint(equalTo: radiusSliderContainer.bottomAnchor, constant: -20),
            radiusSlider.leadingAnchor.constraint(equalTo: radiusSliderContainer.leadingAnchor, constant: 15),
            radiusSlider.trailingAnchor.constraint(equalTo: radiusSliderContainer.trailingAnchor, constant: -15)
        ])
    }
}

extension RadiusSliderView: TooltipedSliderPositionDelegate {
    func didChangeThumbPosition(_ rect: CGRect) {
        let popupRect = rect.offsetBy(dx: 0, dy: -(rect.size.height))
        let maxX = radiusSliderContainer.frame.width - radiusLabel.frame.width
        var labelPosition = popupRect.origin.x + popupRect.width - radiusLabel.frame.width / 2
        labelPosition = labelPosition < 0 ? 0 : labelPosition
        labelPosition = labelPosition > maxX ? maxX : labelPosition
        radiusLabel.transform = CGAffineTransform.identity.translatedBy(x: labelPosition, y: 0)
    }
}
