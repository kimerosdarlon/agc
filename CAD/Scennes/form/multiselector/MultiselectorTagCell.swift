//
//  MultiselectorTagCell.swift
//  CAD
//
//  Created by Samir Chaves on 27/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class IdentifiableButton<K: Equatable>: UIButton {
    var id: K?
}

class MultiselectorTagCell<K: Hashable>: UICollectionViewCell {
    private(set) var selectedTag: SelectedTag<K>?
    private let label = UILabel.build(withSize: 15, color: .white)
    let closeBtn: IdentifiableButton<K> = {
        let btn = IdentifiableButton<K>(type: .close)
        btn.enableAutoLayout()
        btn.backgroundColor = .clear
        btn.setTitleShadowColor(.clear, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(label)
        addSubview(closeBtn)

        layer.cornerRadius = 5
        height(35)
        closeBtn.width(35).height(35)
        bringSubviewToFront(closeBtn)

        NSLayoutConstraint.activate([
            closeBtn.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            closeBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            closeBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with tag: SelectedTag<K>, removable: Bool = true) {
        label.text = tag.label
        closeBtn.id = tag.value
        self.selectedTag = tag

        if removable {
            closeBtn.isHidden = false
        } else {
            closeBtn.isHidden = true
        }
    }
}
