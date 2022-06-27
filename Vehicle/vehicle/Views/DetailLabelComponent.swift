//
//  DetailLabelComponent.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 01/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import Contacts

class DetailLabelComponent: UIStackView {

    var titleLabel: UILabel!
    var detailLabel: UILabel!

    init(title: String, detail: String?) {
        super.init(frame: .zero)
        titleLabel = makeLabel()
        titleLabel.font = UIFont.robotoBold.withSize(14)
        detailLabel = makeLabel()
        titleLabel.text = title
        if detail == nil || detail!.isEmpty {
            detailLabel.text = "-----"
        } else {
            detailLabel.text = detail
        }
        enableAutoLayout()
        self.distribution = .equalSpacing
        spacing = 5
        backgroundColor = .blue
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.axis = .vertical
        addArrangedSubview(titleLabel)
        addArrangedSubview(detailLabel)
    }

    func makeLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.robotoMedium.withSize(12)
        label.textColor = UIColor.white
        label.enableAutoLayout()
        return label
    }

    func makeDetail() -> UITextView {
        let label = UITextView()
        label.isEditable = false
        label.dataDetectorTypes = [.phoneNumber, .address]
        label.font = UIFont.robotoMedium.withSize(12)
        label.textColor = UIColor.white
        label.enableAutoLayout()
        label.enableAutoLayout()
        label.height(20)
        label.isScrollEnabled = false
        label.contentMode = .scaleToFill
        label.textAlignment = .right
        return label
    }
}
