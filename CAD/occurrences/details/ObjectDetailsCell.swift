//
//  ObjectDetailsCell.swift
//  CAD
//
//  Created by Samir Chaves on 27/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

extension UIView {
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
}

extension UITableViewCell {
    var tableView: UITableView? {
        return parentView(of: UITableView.self)
    }
}

class ObjectDetailsCell: ListBasedDetailCell {
    override func getDetailsView() -> UIView {
        guard let parentViewController = self.parentViewController,
              let blockIdentifier = self.block?.identitier,
              let objectId = UUID(uuidString: blockIdentifier) else { return UIView() }
        let container = UIStackView().enableAutoLayout()
        container.axis = .vertical
        container.alignment = .fill
        container.distribution = .fill

        let galleryContainer = UIView().enableAutoLayout()
        let galleryLabel = UILabel.build(withSize: 14, weight: .bold, color: .appTitle, text: "Galeria")
        let listView = super.getDetailsView().enableAutoLayout()
        let gallery = GalleryView(entityId: objectId,
                                  readOnly: true,
                                  picturesPerRow: 5,
                                  parentViewController: parentViewController,
                                  cacheImages: true).enableAutoLayout()
        container.addArrangedSubview(listView)
        galleryContainer.addSubview(galleryLabel)
        galleryContainer.addSubview(gallery)
        container.addArrangedSubview(galleryContainer)
        galleryContainer.backgroundColor = .appBackground

        gallery.height(90)
        galleryContainer.height(110)
        NSLayoutConstraint.activate([
            galleryLabel.topAnchor.constraint(equalTo: galleryContainer.topAnchor),
            galleryLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            galleryLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),

            gallery.topAnchor.constraint(equalTo: galleryContainer.topAnchor, constant: 25),
            gallery.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            gallery.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            galleryContainer.bottomAnchor.constraint(equalTo: gallery.bottomAnchor, constant: 15)
        ])

        return container
    }
}
