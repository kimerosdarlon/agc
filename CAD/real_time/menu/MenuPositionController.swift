//
//  MenuPositionController.swift
//  CAD
//
//  Created by Samir Chaves on 16/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class MenuPositionController {
    enum MenuPosition: CGFloat {
        case top = 1, middle = 0.5, bottom = 0
    }

    var bottomOffset: CGFloat = -25
    var topOffset: CGFloat = 60
    var middleOffset: CGFloat = 0
    var currentPosition: MenuPosition = .bottom
    var parentHeight: CGFloat = 0
    var initialMenuLocation: CGFloat = 0
    var currentMenuLocation: CGFloat = 0
    var marginToFit: CGFloat = 120

    var bottomLocation: CGFloat {
        -MenuPosition.bottom.rawValue * parentHeight + bottomOffset
    }

    var middleLocation: CGFloat {
        -MenuPosition.middle.rawValue * parentHeight + middleOffset
    }

    var topLocation: CGFloat {
        -MenuPosition.top.rawValue * parentHeight + topOffset
    }

    func getMenuLocation(for position: MenuPosition? = nil) -> CGFloat {
        let currentPosition = position ?? self.currentPosition
        switch currentPosition {
        case .bottom:
            return bottomLocation
        case .top:
            return topLocation
        case .middle:
            return middleLocation
        }
    }

    func setMenuPosition() {
        if currentPosition == .bottom && abs(currentMenuLocation - bottomLocation) > abs(middleLocation + marginToFit) {
           self.currentPosition = .top
        } else if currentPosition == .bottom && abs(currentMenuLocation - bottomLocation) < abs(middleLocation + marginToFit) {
            self.currentPosition = .middle
        } else if currentPosition == .middle && (currentMenuLocation - middleLocation) < -marginToFit {
            self.currentPosition = .top
        } else if currentPosition == .middle && (currentMenuLocation - middleLocation) > marginToFit {
            self.currentPosition = .bottom
        } else if currentPosition == .top && (currentMenuLocation - topLocation) < -marginToFit {
            self.currentPosition = .top
        } else if currentPosition == .top && (currentMenuLocation - topLocation) > abs(middleLocation - topLocation) + marginToFit {
            self.currentPosition = .bottom
        } else if currentPosition == .top && (currentMenuLocation - topLocation) > marginToFit {
            self.currentPosition = .middle
        }
    }

    func getMapLocation() -> CGFloat {
        switch currentPosition {
        case .bottom:
            return -12.5
        case .top:
            return -MenuPosition.middle.rawValue * parentHeight / 2
        case .middle:
            return -MenuPosition.middle.rawValue * parentHeight / 2
        }
    }
}
