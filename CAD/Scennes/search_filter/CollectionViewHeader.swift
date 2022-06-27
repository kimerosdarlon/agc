//
//  CollectionViewHeader.swift
//  CAD
//
//  Created by Samir Chaves on 06/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewHeader: UICollectionReusableView {
    let title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14)
        label.textColor = .appTitle
        return label
    }()

}
