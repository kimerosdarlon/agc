//
//  Array+Extension.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 30/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public extension Array {

    mutating func appendIf(_ condition: Bool, _ element: Element ) {
        if condition {
            append(element)
        }
    }

    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public extension Sequence {

    func groupBy<T: Hashable>(path: KeyPath<Element, T> ) -> [T: [Element]] {
        var keys = Set<T>()
        forEach({ keys.insert($0[keyPath: path]) })
        var dict = [T: [Element] ]()
        for key in keys {
            let values = filter({ $0[keyPath: path] == key })
            dict[key] = values
        }
        return dict
    }
}

public extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
