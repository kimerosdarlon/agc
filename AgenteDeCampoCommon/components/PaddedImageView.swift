//
//  PaddedImageView.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 31/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public class PaddedImageView: UIImageView {
    public override var alignmentRectInsets: UIEdgeInsets {
        return UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    }
}
