//
//  AppDefaults.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import ViewPager_Swift

public class AppDefaults {

    public let pagerOptions: ViewPagerOptions = {
        let option = ViewPagerOptions()
        option.viewPagerTransitionStyle = .scroll
        option.tabType = .basic
        option.tabViewHeight = 40
        option.tabIndicatorViewBackgroundColor = .appBlue
        option.tabViewBackgroundDefaultColor = .appBackground
        option.tabViewPaddingLeft = 20
        option.tabViewTextDefaultColor = .appCellLabel
        option.isTabHighlightAvailable = false
        return option
    }()

    public init() {
    }
}
