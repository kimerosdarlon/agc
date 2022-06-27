//
//  Dictionary+Extension.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 15/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public extension Dictionary {

    var toString: String {
        var result = ""
        if let first = self.first {
            result = "\(first.key): \(first.value)"
        }
        if self.count > 1 {
            result += " +\(self.count - 1)"
        }
        return result
    }

    var toStringExpanded: String {
        if self.isEmpty { return "" }
        return self.map({ "\($0.key): \($0.value)" }).joined(separator: ", ")
    }
}

public extension Dictionary where Key == String, Value: Any {

    func object<T: Decodable>() -> T? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: []) {
            return try? JSONDecoder().decode(T.self, from: data)
        } else {
            return nil
        }
    }
}
