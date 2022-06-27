//
//  GalleryCounterView.swift
//  CAD
//
//  Created by Samir Chaves on 20/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import ImageViewer

class GalleryCounterView: UIView {
    var count: Int
    let countLabel = UILabel()
    var currentIndex: Int {
        didSet { updateLabel() }
    }

    init(frame: CGRect, currentIndex: Int, count: Int) {
        self.currentIndex = currentIndex
        self.count = count

        super.init(frame: frame)

        configureLabel()
        updateLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureLabel() {
        countLabel.textAlignment = .center
        self.addSubview(countLabel)
    }

    func updateLabel() {
        let countString = String(format: "%d de %d", arguments: [currentIndex + 1, count])
        countLabel.attributedText = NSAttributedString(string: countString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor.appBackground.withAlphaComponent(0.5)
        layer.cornerRadius = 20
        frame = .init(x: frame.minX, y: frame.minY, width: 100, height: 40)
        countLabel.frame = self.bounds
    }
}
