//
//  CGFloat+Extension.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 07/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public extension CGFloat {
    func getSign() -> CGFloat {
        return self < 0 ? -1 : 1
    }
}
