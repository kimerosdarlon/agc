//
//  CustomTextFieldForm.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 29/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class CustomTextFieldForm: UIStackView, UITextFieldDelegate {
    private(set) var isEdinting = false
    public weak var delegate: CustomTextFieldFormDelegate?

    public var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoMedium.withSize(14)
        label.textColor = .appCellLabel
        label.textAlignment = .left
        label.enableAutoLayout()
        label.height(15)
        return label
    }()

    public let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .appBackgroundCell
        textField.tintColor = .appBlue
        textField.textColor = .appCellLabel
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 20))
        textField.layer.cornerRadius = 5
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.enableAutoLayout()
        textField.height(40)
        return textField
    }()

    private var shouldAddLabel = true

    public  init(label: String?, placeholder: String, keyboardType: UIKeyboardType = .webSearch, height: CGFloat = 80 ) {
        super.init(frame: .zero)
        shouldAddLabel = label != nil
        self.label.text = label
        self.textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholder])
        textField.delegate = self
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        axis = .vertical
        alignment = .fill
        distribution = .fill
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()

    public override func layoutSubviews() {
        super.layoutSubviews()
        insertArrangedSubview(contentStack, at: 0)
        if shouldAddLabel {
            contentStack.addArrangedSubview(label)
        }
        contentStack.addArrangedSubview(textField)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didClickEnter?(textField)
        return true
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.didBeginEdite?(textField)
    }
}

public class CustomTextFieldFormBindable<Model>: CustomTextFieldForm {

    public var path: ReferenceWritableKeyPath<Model, String?>?
    public var children = [CustomTextFieldFormBindable]()
    public init(label: String?, placeholder: String, keyboardType: UIKeyboardType = .webSearch, path: ReferenceWritableKeyPath<Model, String?>, height: CGFloat = 80 ) {
        self.path = path
        super.init(label: label, placeholder: placeholder, keyboardType: keyboardType, height: height)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addChild( _ child: CustomTextFieldFormBindable, orientarion: NSLayoutConstraint.Axis ) {
        axis = orientarion
        spacing = 16
        addArrangedSubview(child)
        alignment = .bottom
        self.children.append(child)
    }
}
