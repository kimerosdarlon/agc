//
//  StatusButton.swift
//  CAD
//
//  Created by Samir Chaves on 31/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class StatusButton: UIView {
    private let statusBtnImage: UIImageView = {
        let imageView = UIImageView().enableAutoLayout()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let statusBtn: UIView = {
        let btn = UIView().enableAutoLayout()
        btn.layer.cornerRadius = 20
        btn.backgroundColor = .appBlue
        return btn
    }()

    func setImage(_ image: UIImage?) {
        statusBtnImage.image = image
    }

    func startLoading() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat]) {
            self.statusBtn.alpha = 0.5
        }
    }

    func endLoading() {
        statusBtn.layer.removeAllAnimations()
        self.statusBtn.alpha = 1
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(statusBtn)
        statusBtn.addSubview(statusBtnImage)

        statusBtn
            .centerX(view: self)
            .centerY(view: self)
            .width(40).height(40)

        statusBtnImage
            .centerX(view: statusBtn)
            .centerY(view: statusBtn)
            .width(22).height(22)
    }
}
