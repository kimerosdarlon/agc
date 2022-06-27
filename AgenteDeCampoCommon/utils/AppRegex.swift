//
//  AppRegex.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 20/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct AppRegex {
    public static let cnhPattern = "^[0-9]+$"
    public static let cpfPattern = "^(\\d{3}\\D?){3}\\d{2}$"
    public static let platePatterns = ["^[a-zA-Z]{3}\\s?(\\-)?\\s?\\d[a-zA-Z0-9]\\d{2}$"]
    public static let cnpjPattern = "^\\d{2}.?\\d{3}.?\\d{3}\\/?\\d{4}-?\\d{2}$"
    public static let chassiPattern = "^\\w{17}$"
    public static let phonePattern = "\\(?\\d{2}\\)?\\s?\\d{4,5}-?\\d{4}"
    public static let protocolPattern = "^\\w{19,35}$"
    public static let codeNationalPattern = "^[0-9]{8}-?[0-9]{2}\\/?[0-9]{4}\\/?[0-9]{7}$"
    public static let personNamePattern = "^[a-z]{2,}(\\s+[a-z]{2,})*$"
}

public struct AppMask {
    public static let cpfMask = "###.###.###-##"
    public static let codeNational = "########-##/####/#######"
    public static let cnpjMask = "##.###.###/####-##"
    public static let dateMask = "##/##/####"
    public static let timeMask = "##:##"
    public static let plateMask = "###-####"
    public static let phoneMask = "(##) #####-####"
}

public func cpfMask(_ value: String?, hidden: Bool = false) -> String? {
    guard let cpf = value else { return nil }
    if cpf.count > 14 { return String(cpf.dropLast()) }
    if hidden {
        let hiddenCpfMask = "***.***.###-##"
        if let value = value, value.count == 11 {
            return value[6..<value.count].apply(pattern: hiddenCpfMask, replacmentCharacter: "#")
        } else {
            return nil
        }
    }
    return value?.apply(pattern: AppMask.cpfMask, replacmentCharacter: "#")
}

public func dateMask(_ value: String? ) -> String? {
    guard let date = value else { return nil }
    if date.count > 10 { return String(date.dropLast()) }
    return value?.apply(pattern: AppMask.dateMask, replacmentCharacter: "#")
}

public func timeMask(_ value: String? ) -> String? {
    guard let time = value else { return nil }
    if time.count > 5 { return String(time.dropLast()) }
    return value?.apply(pattern: AppMask.timeMask, replacmentCharacter: "#")
}
