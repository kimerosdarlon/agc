//
//  TextFieldMask.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 29/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class TextFieldMask: NSObject, UITextFieldDelegate {

    private var patterns = [String]()
    private var uppercased = true
    private var index = 0
    private var patternToUse = ""
    private var flag = true
    public weak var delegate: CustomTextFieldFormDelegate?

    public convenience init(pattern: String, uppercased: Bool = true) {
        self.init(patterns: [pattern], uppercased: uppercased)
    }

    public init(patterns: [String], uppercased: Bool = true) {
        super.init()
        self.uppercased = uppercased
        set(patterns: patterns)
    }

    public func set(patterns: [String]) {
        patternToUse = ""
        flag = false
        self.patterns = patterns.sorted { (pattern1, pattern2) -> Bool in
            return pattern1.count < pattern2.count
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let isDeleting = range.length == 1
        if patterns.isEmpty || isDeleting {
            flag = true
            return true
        }
        let text = (textField.text ?? "")
        for pattern in patterns {
            if text.count > pattern.count - 1 {
                flag = false
            } else {
                patternToUse = pattern
                flag = true
                break
            }
        }

        let formattedString = string.apply(pattern: patternToUse, replacmentCharacter: "#")
        if string.count > 1 && formattedString.count > patternToUse.count {
            return false
        }

        return flag
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        if uppercased {
            textField.text = textField.text?.uppercased()
        }
        if flag {
            textField.text = textField.text?.apply(pattern: patternToUse, replacmentCharacter: "#")
        }
        delegate?.didBeginEdite?(textField)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didClickEnter?(textField)
        return true
    }
}
