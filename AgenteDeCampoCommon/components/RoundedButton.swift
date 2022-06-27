//
//  RoundedeButton.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 30/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class AGCRoundedButton: UIButton {
    var text: String!
    var loadingText: String!

    private var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.enableAutoLayout()
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        return loadingIndicator
    }()

    public init(text: String, loadingText: String = "") {
        super.init(frame: .zero)
        enableAutoLayout()
        self.loadingText = loadingText
        self.text = text
        titleLabel?.font = UIFont.robotoMedium.withSize(15)
        titleLabel?.textColor = .label
        backgroundColor = .appBlue
        layer.cornerRadius = 5
        layer.masksToBounds = true
        setTitle(text, for: .normal)
        setTitleColor(.white, for: .disabled)
        setTitleColor(UIColor.lightGray, for: .highlighted)
        addSubview(loadingIndicator)
        loadingIndicator.fillSuperView()
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    @discardableResult
    public func setRightIcon(_ icon: UIImage) -> Self {
        semanticContentAttribute = .forceRightToLeft
        setImage(icon, for: .normal)
        tintAdjustmentMode = .automatic
        imageEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: -2)
        return self
    }

    override public var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            if isEnabled {
                self.backgroundColor = .appBlue
            } else {
                self.backgroundColor = .lightGray
            }
        }
    }

    public func startLoad() {
        DispatchQueue.main.async {[weak self] in
            self?.isEnabled = false
            self?.setTitle(self?.loadingText, for: .disabled)
            self?.loadingIndicator.startAnimating()
        }
    }

    public func stopLoad() {
        DispatchQueue.main.async { [weak self] in
            self?.isEnabled = true
            self?.setTitle(self?.text, for: .disabled)
            self?.loadingIndicator.stopAnimating()
        }
    }
}
