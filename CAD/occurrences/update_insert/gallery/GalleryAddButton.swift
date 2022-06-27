//
//  GalleryAddButton.swift
//  CAD
//
//  Created by Samir Chaves on 17/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class GalleryAddButton: UICollectionViewCell {
    static let identifier = String(describing: GalleryAddButton.self)

    private let cameraIcon: UIImageView = {
        let image = UIImage(systemName: "camera.fill")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let view = UIImageView(image: image).enableAutoLayout()
        return view.width(30).height(25)
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        layer.cornerRadius = 5
        clipsToBounds = true
        backgroundColor = .appBackgroundCell

        addSubview(cameraIcon)
        cameraIcon.centerX(view: self).centerY(view: self)
    }
}
