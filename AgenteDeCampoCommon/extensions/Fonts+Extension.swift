//
//  Fonts.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 22/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public extension UIFont {

    static var firaSansBoldItalic: UIFont = {
        return UIFont(name: "FiraSans-BoldItalic", size: .defaultFontSize)!
    }()

    static var firaSansSemiBold: UIFont = {
        return UIFont(name: "FiraSans-SemiBold", size: .defaultFontSize)!
    }()

    static var robotoRegular: UIFont = {
        return UIFont(name: "Roboto-Regular", size: .defaultFontSize)!
    }()

    static var robotoMedium: UIFont = {
        return UIFont(name: "Roboto-Medium", size: .defaultFontSize)!
    }()

    static var robotoItalic: UIFont = {
        return UIFont(name: "Roboto-Italic", size: .defaultFontSize)!
    }()

    static var robotoBold: UIFont = {
        return UIFont(name: "Roboto-Bold", size: .defaultFontSize)!
    }()

    static var appSmallTitle: UIFont = {
        return UIFont.firaSansSemiBold.withSize(.smallTitleFontSize)
    }()

    static var appLargeTitle: UIFont = {
        return UIFont.firaSansBoldItalic.withSize(.largeTitleFontSize)
    }()

    static var appCollectionCell: UIFont = {
        return UIFont.robotoRegular.withSize(14)
    }()
}

public extension CGFloat {

    static var defaultFontSize: CGFloat = {
        return 15
    }()

    static var smallTitleFontSize: CGFloat = {
        return 20
    }()

    static var largeTitleFontSize: CGFloat = {
        return 24
    }()
}
