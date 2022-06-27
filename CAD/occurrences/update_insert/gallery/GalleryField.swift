//
//  GalleryField.swift
//  CAD
//
//  Created by Samir Chaves on 21/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class GalleryField: UIView {
    private let galleryView: GalleryView

    private let titleLabel = UILabel.build(withSize: 14, weight: .bold, color: .appTitle)

    init(label: String, entityId: UUID, parentViewController: UIViewController) {
        self.galleryView = GalleryView(entityId: entityId, parentViewController: parentViewController)

        super.init(frame: .zero)

        self.titleLabel.text = label
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(titleLabel)
        galleryView.enableAutoLayout()
        addSubview(galleryView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            galleryView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            galleryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            galleryView.trailingAnchor.constraint(equalTo: trailingAnchor),
            galleryView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}
