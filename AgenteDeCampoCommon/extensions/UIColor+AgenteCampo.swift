//
//  UIColor+AgenteCampo.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 22/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public extension UIColor {

    static var appGreenMarker: UIColor = {
        return UIColor(named: "appGreenMarker")!
    }()

    static var appBlue: UIColor = {
        return UIColor(named: "appBlue")!
    }()

    static var appBackground: UIColor = {
         return colorWith(name: "appBackground")
    }()

    static var appBackgroundCell: UIColor = {
         return colorWith(name: "appBackgroundCell")
    }()

    static var appCellLabel: UIColor = {
        return colorWith(name: "appCellLabel")
    }()

    static var appBackgroundTabbar: UIColor = {
        return colorWith(name: "appBackgroundTabbar")
    }()

    static var appLightGray: UIColor = {
        return colorWith(name: "appLightGray")
    }()

    static var appTitle: UIColor = {
        return colorWith(name: "appTitle")
    }()

    static var appBlack: UIColor = {
        return UIColor(named: "appBlack")!
    }()

    static var textFieldPlaceholder: UIColor = {
        return colorWith(name: "textFieldPlaceholder").withAlphaComponent(0.5)
    }()

    static var textField: UIColor = {
        return colorWith(name: "textField")
    }()

    static var appRed: UIColor = {
        return colorWith(name: "appRed")
    }()

    static var appPurple: UIColor = {
        return UIColor(named: "appPurple")!
    }()

    static var appYellow: UIColor = {
        return colorWith(name: "appYellow")
    }()

    static var appCyan: UIColor = {
        return colorWith(name: "appCyan")
    }()

    static var appRedAlert: UIColor = {
        return colorWith(name: "appRedAlert")
    }()

    static var chassisBold: UIColor = {
        return colorWith(name: "chassisBold")
    }()

    static var appSectionHeader: UIColor = {
        return colorWith(name: "appSectionHeader")
    }()

    static var imageBackGround: UIColor = {
        return UIColor(named: "imageBackGround")!
    }()

    static var appWarning: UIColor = {
        return UIColor(named: "appWarning")!
    }()

    static var memberBackGroundCell: UIColor = {
        return colorWith(name: "memberBackGroundCell")
    }()

    static var transparent: UIColor = {
        return UIColor.white.withAlphaComponent(0)
    }()

    func lighter(by percentage: CGFloat = 0.3) -> UIColor {
      return self.adjustBrightness(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 0.3) -> UIColor {
      return self.adjustBrightness(by: -abs(percentage))
    }

    func adjustBrightness(by percentage: CGFloat = 0.3) -> UIColor {
      var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
        if b < 1.0 {
          let newB: CGFloat = max(min(b + (percentage)*b, 1.0), 0.0)
          return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
        } else {
          let newS: CGFloat = min(max(s - (percentage)*s, 0.0), 1.0)
          return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
        }
      }
      return self
    }
}

private func colorWith(name: String) -> UIColor {
    return UIColor { (traitCollection) -> UIColor in
        let systemIsDark = traitCollection.userInterfaceStyle == .dark
        if let lightColor = UIColor(named: name), let darkColor = UIColor(named: "\(name)Dark") {
            let userTheme = UserStylePreferences.theme
            switch userTheme {
            case .dark:
                return darkColor
            case .white:
                return lightColor
            case .system:
                return systemIsDark ? darkColor : lightColor
            }
        }
        return UIColor.clear
    }
}
