//
//  String+AgenteCampo.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 28/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import CryptoKit

public extension String {

    func onlyNumbers() -> String {
        guard !isEmpty else { return "" }
        return replacingOccurrences(of: "\\D",
                                    with: "",
                                    options: .regularExpression,
                                    range: startIndex..<endIndex)
    }

    func onlyStandardCharacters() -> String {
        guard !isEmpty else { return "" }
        return replacingOccurrences(of: "\\W",
                                    with: "",
                                    options: .regularExpression,
                                    range: startIndex..<endIndex)
    }

    func apply(pattern: String, replacmentCharacter: Character ) -> String {
        var pureStr = self.replacingOccurrences( of: "\\W", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureStr.count else { return pureStr }
            let stringIndex = String.Index(utf16Offset: index, in: pureStr)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureStr.insert(patternCharacter, at: stringIndex)
        }
        return pureStr
    }

    static func interpolateString(values: [String?], separators origSeparators: [String]) -> String {
        var separators = origSeparators.map { $0 }
        var resultList = [[String]]()

        if separators.count == values.count + 1 {
            resultList.append([separators.first!])
            _ = separators.removeFirst()
        } else if separators.count == values.count - 1 {
            separators.append("")
        } else if separators.count != values.count {
            return ""
        }

        for (value, separator) in zip(values, separators) where value != nil {
            resultList.append([value!, separator])
        }

        if let lastSeparator = resultList.last?.last, !lastSeparator.isEmpty {
            let result = "\(resultList.flatMap { $0 }.joined())"
            let rangeStart = result.index(result.endIndex, offsetBy: -lastSeparator.count)
            let rangeEnd = result.endIndex
            let range = rangeStart..<rangeEnd
            return result.replacingCharacters(in: range, with: "")
        }

        return resultList.flatMap { $0 }.joined()
    }
}

public extension String {

    var blockList: [String] {
        return [
            "11111111111",
            "22222222222",
            "33333333333",
            "44444444444",
            "55555555555",
            "66666666666",
            "77777777777",
            "88888888888",
            "99999999999",
            "00000000000"
        ]
    }

    var isCPF: Bool {
        let pattern = "^\\d"
        let startWithDigit = self.matches(in: pattern)
        if !startWithDigit { return false }
        var cpf = self.onlyStandardCharacters()
        guard cpf.count == 11 else { return false }
        cpf = cpf.onlyNumbers()
        guard cpf.count == 11 else { return false }
        if blockList.contains(cpf) { return false }

        let index1 = cpf.index(cpf.startIndex, offsetBy: 9)
        let index2 = cpf.index(cpf.startIndex, offsetBy: 10)
        let index3 = cpf.index(cpf.startIndex, offsetBy: 11)
        let data1 = Int(cpf[index1..<index2])
        let data2 = Int(cpf[index2..<index3])

        var temp1 = 0, temp2 = 0

        for index in 0...8 {
            let start = cpf.index(cpf.startIndex, offsetBy: index)
            let end = cpf.index(cpf.startIndex, offsetBy: index+1)
            let char = Int(cpf[start..<end])

            temp1 += char! * (10 - index)
            temp2 += char! * (11 - index)
        }

        temp1 %= 11
        temp1 = temp1 < 2 ? 0 : 11-temp1

        temp2 += temp1 * 2
        temp2 %= 11
        temp2 = temp2 < 2 ? 0 : 11-temp2

        return temp1 == data1 && temp2 == data2
    }

    var isCNPJ: Bool {
        let pattern = "^\\d"
        let startWithDigit = self.matches(in: pattern)
        if !startWithDigit { return false }
        let numbers = compactMap(\.wholeNumberValue)
        guard numbers.count == 14 && Set(numbers).count != 1 else { return false }
        return numbers.prefix(12).digitoCNPJ == numbers[12] &&
            numbers.prefix(13).digitoCNPJ == numbers[13]
    }

    var applyCpfORCnpjMask: String {
        if self.isCPF {
            return self.apply(pattern: "###.###.###-##", replacmentCharacter: "#")
        } else if self.isCNPJ {
            return self.apply(pattern: "##.###.###/####-##", replacmentCharacter: "#")
        }
        return self
    }

    func equalIgnoreCase(_ other: String) -> Bool {
        return self.lowercased().elementsEqual(other.lowercased())
    }

    func hmacSHA256(secret: String, salt: String) throws -> String {
        let saltedMessage = "\(self)\(salt)"
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), secret, secret.count, saltedMessage, saltedMessage.count, &digest)
        return Data(digest).base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}

public extension String {

    func matches(in pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return !results.isEmpty
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }

    func matches(inAny patterns: [String]) -> Bool {
        do {
            for pattern in patterns {
                let regex = try NSRegularExpression(pattern: pattern)
                let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
                return !results.isEmpty
            }
            return false
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }

    func prepareForSearch() -> String {
        return self
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public extension Collection where Element == Int {
    var digitoCNPJ: Int {
        var number = 1
        let digit = 11 - reversed().reduce(into: 0) {
            number += 1
            $0 += $1 * number
            if number == 9 { number = 1 }
            } % 11
        return digit > 9 ? 0 : digit
    }
}
